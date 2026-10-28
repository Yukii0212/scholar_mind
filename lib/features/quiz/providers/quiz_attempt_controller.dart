import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/quiz_repository.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_attempt.dart';
import '../domain/question_type.dart';
import '../services/openai_quiz_service.dart';

class QuizAttemptController extends StateNotifier<QuizAttempt?> {
  QuizAttemptController(
    this._repository,
    this._openAI, {
    required String? userId,
    required bool Function() isSessionCurrent,
  })  : _userId = userId,
        _isSessionCurrent = isSessionCurrent,
        super(null);

  final QuizRepository _repository;

  final OpenAIQuizService _openAI;
  final String? _userId;
  final bool Function() _isSessionCurrent;

  Timer? _idleTimer;

  Timer? _dirtyTimer;

  bool _dirty = false;
  bool _isDisposed = false;

  QuizAttempt? get currentAttempt => state;

  String get _activeUserId {
    final userId = _userId;

    if (_isDisposed || userId == null || !_isSessionCurrent()) {
      throw StateError(
        'The signed-in account changed while the quiz was active.',
      );
    }

    return userId;
  }

  Future<void> startAttempt(
    QuizAttempt attempt,
  ) async {
    _activeUserId;
    state = attempt;
    _dirty = true;

    await saveNow();
  }

  Future<void> restoreAttempt({
    required QuizAttempt attempt,
  }) async {
    _activeUserId;
    state = attempt;
  }

  void updateAnswer({
    required int questionIndex,
    required QuizAnswer answer,
  }) {
    if (state == null ||
        _isDisposed ||
        _userId == null ||
        !_isSessionCurrent()) {
      return;
    }

    final updatedAnswers = Map<int, QuizAnswer>.from(
      state!.answers,
    );

    updatedAnswers[questionIndex] = answer;

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

    _activeUserId;

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

    final payload = <Map<String, String>>[];

    state!.quiz.questions.asMap().forEach(
      (index, question) {
        if (question.type != QuestionType.openEnded) {
          return;
        }

        payload.add({
          'questionIndex': '$index',
          'question': question.question,
          'sampleAnswer': question.sampleAnswer ?? '',
          'studentAnswer': state!.answers[index]?.openEndedAnswer ?? '',
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

    final result = await _openAI.evaluateOpenEndedAnswers(
      answers: payload,
    );

    _activeUserId;

    if (state == null) {
      return;
    }

    final updated = Map<int, QuizAnswer>.from(
      state!.answers,
    );

    for (final evaluation in result) {
      final index = int.parse(
        evaluation['questionIndex'].toString(),
      );

      updated[index] = (updated[index] ?? const QuizAnswer()).copyWith(
        aiReviewPending: false,
        aiScore: evaluation['score'] as int?,
        aiMaxScore: evaluation['maxScore'] as int?,
        aiFeedback: evaluation['feedback'] as String?,
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
    if (!_dirty || state == null) {
      return;
    }

    final userId = _activeUserId;
    final attempt = state!;

    _dirty = false;

    _idleTimer?.cancel();
    _idleTimer = null;

    _dirtyTimer?.cancel();
    _dirtyTimer = null;

    try {
      await _repository.saveCurrentAttempt(
        userId: userId,
        json: attempt.toJson(),
      );

      _activeUserId;

      await _repository.saveAttemptToCloud(
        userId: userId,
        attempt: attempt,
      );

      _activeUserId;
    } catch (_) {
      if (!_isDisposed && _userId != null && _isSessionCurrent()) {
        _dirty = true;
      }

      rethrow;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _idleTimer?.cancel();
    _dirtyTimer?.cancel();
    super.dispose();
  }

  Future<void> retryAttempt() async {
    if (state == null) {
      return;
    }

    _activeUserId;

    state = state!.reset();

    _dirty = true;

    await saveNow();
  }
}
