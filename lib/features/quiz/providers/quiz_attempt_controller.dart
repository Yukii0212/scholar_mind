import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/quiz_repository.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_attempt.dart';
import '../domain/question_type.dart';
import '../services/openai_quiz_service.dart';
import 'quiz_provider.dart';

class QuizAttemptController
    extends StateNotifier<QuizAttempt?> {

  QuizAttemptController(
      this._repository,
      this._openAI,
      this._ref,
      ) : super(null);

  final QuizRepository _repository;

  final OpenAIQuizService _openAI;
  final Ref _ref;

  Timer? _idleTimer;

  Timer? _dirtyTimer;

  bool _dirty = false;

  Future<void> startAttempt(
      QuizAttempt attempt,
      ) async {
    state = attempt;

    await saveNow();
  }

  Future<void> restoreAttempt({
    required QuizAttempt attempt,
  }) async {
    state = attempt;
  }

  void updateAnswer({
    required int questionIndex,
    required QuizAnswer answer,
  }) {
    if (state == null) {
      return;
    }

    final updatedAnswers =
    Map<int, QuizAnswer>.from(
      state!.answers,
    );

    updatedAnswers[questionIndex] =
        answer;

    state = state!.copyWith(
      answers: updatedAnswers,
      updatedAt: DateTime.now(),
    );

    _markDirty();
  }

  /// Fully awaits the entire grading pipeline (open-ended AI review
  /// included), rather than firing it off unawaited -- callers decide
  /// whether to await this directly (objective-only quizzes, where it
  /// resolves almost instantly) or run it through AppTaskController
  /// (quizzes with open-ended questions, where the AI round-trip can take
  /// real time and the caller wants it to keep going even if the quiz
  /// screen is left).
  Future<void> startGrading() async {
    if (state == null) {
      return;
    }

    // Marked pending BEFORE saving so that if grading is interrupted
    // (app closed mid-review), the persisted attempt correctly shows
    // which open-ended answers still need a real AI review, rather than
    // silently defaulting to "already reviewed" with a 0 score -- this is
    // also what lets a stuck attempt be detected and resumed later (see
    // quiz_result_screen.dart's resume-if-stuck check).
    final markedAnswers = Map<int, QuizAnswer>.from(state!.answers);

    state!.quiz.questions.asMap().forEach((index, question) {
      if (question.type == QuestionType.openEnded) {
        markedAnswers[index] =
            (markedAnswers[index] ?? const QuizAnswer()).copyWith(
          aiReviewPending: true,
        );
      }
    });

    state = state!.copyWith(
      answers: markedAnswers,
      status: QuizAttemptStatus.grading,
      submittedAt: DateTime.now(),
    );

    _dirty = true;

    await saveNow();

    await _evaluateOpenEnded();
  }

  Future<void> _evaluateOpenEnded() async {
    if (state == null) {
      return;
    }

    final payload =
    <Map<String, String>>[];

    state!.quiz.questions
        .asMap()
        .forEach(
          (index, question) {
        if (question.type !=
            QuestionType.openEnded) {
          return;
        }

        payload.add({
          'questionIndex':
          '$index',
          'question':
          question.question,
          'sampleAnswer':
          question.sampleAnswer ??
              '',
          'studentAnswer':
          state!
              .answers[index]
              ?.openEndedAnswer ??
              '',
        });
      },
    );

    if (payload.isEmpty) {

      state = state!.copyWith(
        status: QuizAttemptStatus.completed,
        completedAt: DateTime.now(),
      );

      _dirty = true;

      await saveNow();

      return;
    }

    final result =
    await _openAI
        .evaluateOpenEndedAnswers(
      answers: payload,
    );

    if (state == null) {
      return;
    }

    final updated =
    Map<int, QuizAnswer>.from(
      state!.answers,
    );

    for (final evaluation
    in result) {
      final index = int.parse(
        evaluation[
        'questionIndex']
            .toString(),
      );

      updated[index] =
          (updated[index] ??
              const QuizAnswer())
              .copyWith(
            aiReviewPending: false,
            aiScore:
            evaluation['score']
            as int?,
            aiMaxScore:
            evaluation[
            'maxScore'] as int?,
            aiFeedback:
            evaluation[
            'feedback'] as String?,
          );
    }

    state = state!.copyWith(
      answers: updated,
      status: QuizAttemptStatus.completed,
      completedAt: DateTime.now(),
    );

    _dirty = true;

    await saveNow();
  }

  void _markDirty() {
    _dirty = true;

    _idleTimer?.cancel();

    _idleTimer = Timer(
      const Duration(
        seconds: 10,
      ),
      saveNow,
    );

    _dirtyTimer ??= Timer(
      const Duration(
        seconds: 30,
      ),
      saveNow,
    );
  }

  Future<void> saveNow() async {
    if (!_dirty ||
        state == null) {
      return;
    }

    final attempt = state!;

    _dirty = false;

    _idleTimer?.cancel();
    _idleTimer = null;

    _dirtyTimer?.cancel();
    _dirtyTimer = null;

    await _repository.saveCurrentAttempt(
      attempt.toJson(),
    );

    await _repository.saveAttemptToCloud(
      attempt,
    );
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _dirtyTimer?.cancel();
    super.dispose();
  }

  Future<void> retryAttempt() async {

    if (state == null) {
      return;
    }

    state = state!.reset();

    _dirty = true;

    await saveNow();

  }
}