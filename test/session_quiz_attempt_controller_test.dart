import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:scholar_mind/features/quiz/data/quiz_repository.dart';
import 'package:scholar_mind/features/quiz/domain/quiz_attempt.dart';
import 'package:scholar_mind/features/quiz/domain/quiz_response.dart';
import 'package:scholar_mind/features/quiz/providers/quiz_attempt_controller.dart';
import 'package:scholar_mind/features/quiz/services/openai_quiz_service.dart';

class _BlockingQuizRepository extends QuizRepository {
  final localSaveStarted = Completer<void>();
  final releaseLocalSave = Completer<void>();

  final List<String> localSaveUsers = [];
  final List<String> cloudSaveUsers = [];

  @override
  Future<void> saveCurrentAttempt({
    required String userId,
    required Map<String, dynamic> json,
  }) async {
    localSaveUsers.add(userId);
    localSaveStarted.complete();
    await releaseLocalSave.future;
  }

  @override
  Future<void> saveAttemptToCloud({
    required String userId,
    required QuizAttempt attempt,
  }) async {
    cloudSaveUsers.add(userId);
  }
}

void main() {
  test('an account change stops an in-flight attempt before cloud save',
      () async {
    final repository = _BlockingQuizRepository();
    var sessionIsCurrent = true;
    final controller = QuizAttemptController(
      repository,
      const OpenAIQuizService(),
      userId: 'account-a',
      isSessionCurrent: () => sessionIsCurrent,
    );
    addTearDown(controller.dispose);

    final now = DateTime(2026, 1, 1);
    final attempt = QuizAttempt(
      id: 'attempt-a',
      quiz: const QuizResponse(
        title: 'Session test',
        questions: [],
      ),
      answers: const {},
      status: QuizAttemptStatus.inProgress,
      startedAt: now,
      name: 'Session test',
      folderId: 'root',
      createdAt: now,
      updatedAt: now,
    );

    final save = controller.startAttempt(attempt);
    await repository.localSaveStarted.future;

    sessionIsCurrent = false;
    repository.releaseLocalSave.complete();

    await expectLater(save, throwsStateError);
    expect(repository.localSaveUsers, ['account-a']);
    expect(repository.cloudSaveUsers, isEmpty);
  });
}
