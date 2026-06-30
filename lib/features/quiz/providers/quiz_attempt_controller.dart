import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/quiz_repository.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_attempt.dart';
import '../domain/question_type.dart';
import '../services/openai_quiz_service.dart';

class QuizAttemptController
    extends StateNotifier<QuizAttempt?> {

  QuizAttemptController(
      this._repository,
      this._openAI,
      ) : super(null);

  final QuizRepository _repository;

  final OpenAIQuizService _openAI;

  Timer? _idleTimer;

  Timer? _dirtyTimer;

  bool _dirty = false;

  void startAttempt(
      QuizAttempt attempt,
      ) {
    if (state != null) {
      return;
    }

    state = attempt;
  }

  void updateAnswer({
    required int questionIndex,
    required QuizAnswer answer,
  }) {
    if (state == null) {
      return;
    }

    final updated =
    Map<int, QuizAnswer>.from(
      state!.answers,
    );

    updated[questionIndex] = answer;

    state = state!.copyWith(
      answers: updated,
    );

    _markDirty();
  }

  Future<void> submitAttempt() async {
    if (state == null) {
      return;
    }

    state = state!.copyWith(
      status:
      QuizAttemptStatus.submitted,
      submittedAt:
      DateTime.now(),
    );

    _saveNow();

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
      status:
      QuizAttemptStatus.completed,
      completedAt: DateTime.now(),
    );

    await _saveNow();
  }

  void _markDirty() {
    _dirty = true;

    _idleTimer?.cancel();

    _idleTimer = Timer(
      const Duration(
        seconds: 10,
      ),
      _saveNow,
    );

    _dirtyTimer ??= Timer(
      const Duration(
        seconds: 30,
      ),
      _saveNow,
    );
  }

  Future<void> _saveNow() async {
    if (!_dirty ||
        state == null) {
      return;
    }

    _dirty = false;

    _idleTimer?.cancel();
    _idleTimer = null;

    _dirtyTimer?.cancel();
    _dirtyTimer = null;

    await _repository.saveAttempt(
      state!.toJson(),
    );
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _dirtyTimer?.cancel();
    super.dispose();
  }
}