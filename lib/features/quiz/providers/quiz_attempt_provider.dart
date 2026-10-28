import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../domain/quiz_attempt.dart';
import '../services/openai_quiz_service.dart';
import 'quiz_repository_provider.dart';
import 'quiz_attempt_controller.dart';

final quizAttemptProvider =
    StateNotifierProvider<QuizAttemptController, QuizAttempt?>(
  (ref) {
    final userId = ref.watch(
      activeUserProvider.select((user) => user?.uid),
    );

    return QuizAttemptController(
      ref.read(
        quizRepositoryProvider,
      ),
      const OpenAIQuizService(),
      userId: userId,
      isSessionCurrent: () {
        return ref.read(activeUserProvider)?.uid == userId;
      },
    );
  },
);
