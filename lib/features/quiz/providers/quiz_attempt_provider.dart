import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quiz_attempt.dart';
import '../services/openai_quiz_service.dart';
import 'quiz_repository_provider.dart';
import 'quiz_attempt_controller.dart';

final quizAttemptProvider =
StateNotifierProvider<
    QuizAttemptController,
    QuizAttempt?>(
      (ref) {
        return QuizAttemptController(
          ref.read(
            quizRepositoryProvider,
          ),
          const OpenAIQuizService(),
          ref,
        );
  },
);