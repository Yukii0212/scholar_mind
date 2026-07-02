import '../services/study_material_preprocessor.dart';
import '../domain/quiz_attempt.dart';
import '../domain/quiz_response.dart';
import '../services/openai_quiz_service.dart';
import '../services/quiz_local_cache_service.dart';

class QuizRepository {

  const QuizRepository({
    this.openAI =
    const OpenAIQuizService(),
    this.localCache =
    const QuizLocalCacheService(),
  });

  final OpenAIQuizService openAI;

  final QuizLocalCacheService
  localCache;

  Future<String> buildStudyContext({
    required List<ProcessedStudyMaterial> lectureNotes,
    required List<ProcessedStudyMaterial> pastYearQuestions,
  }) async {
    final buffer = StringBuffer();

    if (lectureNotes.isNotEmpty) {
      buffer.writeln('=== Lecture Notes ===');
      buffer.writeln();

      for (final material in lectureNotes) {
        buffer.writeln(
          'File: ${material.note.name}',
        );
        buffer.writeln();
        buffer.writeln(material.text);
        buffer.writeln();
        buffer.writeln(
          '----------------------------------------',
        );
        buffer.writeln();
      }
    }

    if (pastYearQuestions.isNotEmpty) {
      if (buffer.isNotEmpty) {
        buffer.writeln();
      }

      buffer.writeln(
        '=== Past Year Questions ===',
      );
      buffer.writeln();

      for (final material in pastYearQuestions) {
        buffer.writeln(
          'File: ${material.note.name}',
        );
        buffer.writeln();
        buffer.writeln(material.text);
        buffer.writeln();
        buffer.writeln(
          '----------------------------------------',
        );
        buffer.writeln();
      }
    }

    return buffer.toString().trim();
  }

  Future<void> saveCurrentAttempt(
      Map<String, dynamic> json,
      ) {
    return localCache.saveAttempt(json);
  }

  Future<Map<String, dynamic>?>
  restoreCurrentAttempt() async {
    return await localCache.loadCurrentAttempt();
  }

  Future<void> clearCurrentAttempt() {
    return localCache.clearCurrentAttempt();
  }

  Future<QuizAttempt?> restoreQuizAttempt({
    required QuizResponse quiz,
  }) async {
    final json =
    await restoreCurrentAttempt();

    if (json == null) {
      return null;
    }

    return QuizAttempt.fromJson(
      quiz: quiz,
      json: json,
    );
  }

  Future<List<QuizAttempt>> getSavedAttempts() async {
    return [];
  }

  Future<void> saveCompletedAttempt(
      QuizAttempt attempt,
      ) async {}

  Future<void> deleteAttempt(
      String attemptId,
      ) async {}
}