import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quiz_attempt.dart';

final quizAttemptProvider =
StateNotifierProvider.autoDispose<
    QuizAttemptController,
    QuizAttempt?>(
      (ref) {
    return QuizAttemptController();
  },
);

class QuizAttemptController
    extends StateNotifier<QuizAttempt?> {

  QuizAttemptController()
      : super(null);

  void startAttempt(
      QuizAttempt attempt,
      ) {
    state = attempt;
  }

  void updateAnswer({
    required int questionIndex,
    required dynamic answer,
  }) {
    if (state == null) {
      return;
    }

    final updated =
    Map<int, dynamic>.from(
      state!.answers,
    );

    updated[questionIndex] = answer;

    state = state!.copyWith(
      answers:
      updated.cast(),
    );
  }

  void submit() {
    if (state == null) {
      return;
    }

    state = state!.copyWith(
      status:
      QuizAttemptStatus.submitted,
      submittedAt:
      DateTime.now(),
    );
  }

  void complete() {
    if (state == null) {
      return;
    }

    state = state!.copyWith(
      status:
      QuizAttemptStatus.completed,
      completedAt:
      DateTime.now(),
    );
  }

  void replaceAttempt(
      QuizAttempt attempt,
      ) {
    state = attempt;
  }

  void clear() {
    state = null;
  }
}