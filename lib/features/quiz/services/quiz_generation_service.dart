import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/quiz_library_repository.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz_attempt.dart';
import '../domain/quiz_generation_request.dart';
import '../domain/quiz_response.dart';
import 'openai_quiz_service.dart';
import 'quiz_prompt_builder.dart';

class QuizGenerationService {
  const QuizGenerationService();

  Future<QuizAttempt> generate({
    required String userId,
    required QuizGenerationRequest request,
    required String destinationFolderId,
    void Function(String message)? onProgress,
    void Function()? ensureSessionCurrent,
  }) async {
    ensureSessionCurrent?.call();

    onProgress?.call(
      'Generating quiz...',
    );

    final prompt = const QuizPromptBuilder().build(request);

    final QuizResponse quiz = await const OpenAIQuizService().generateQuiz(
      studyContext: request.studyContext,
      instructions: prompt,
    );

    ensureSessionCurrent?.call();

    onProgress?.call(
      'Saving quiz...',
    );

    final now = DateTime.now();

    final attempt = QuizAttempt(
      id: now.millisecondsSinceEpoch.toString(),
      quiz: quiz,
      name: quiz.title,
      folderId: destinationFolderId,
      createdAt: now,
      updatedAt: now,
      answers: const {},
      status: QuizAttemptStatus.inProgress,
      startedAt: now,
    );

    final repository = QuizRepository();

    await repository.saveCurrentAttempt(
      userId: userId,
      json: attempt.toJson(),
    );

    ensureSessionCurrent?.call();

    await QuizLibraryRepository(
      FirebaseFirestore.instance,
    ).createQuiz(
      userId: userId,
      quiz: attempt,
    );

    ensureSessionCurrent?.call();

    return attempt;
  }
}
