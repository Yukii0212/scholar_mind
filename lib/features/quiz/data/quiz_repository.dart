import '../services/study_material_preprocessor.dart';
import '../domain/quiz_attempt.dart';
import '../domain/quiz_response.dart';
import '../services/openai_quiz_service.dart';
import '../services/quiz_local_cache_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizRepository {
  QuizRepository({
    this.openAI = const OpenAIQuizService(),
    this.localCache = const QuizLocalCacheService(),
    FirebaseFirestore? firestore,
  }) : _firestore = firestore;

  final OpenAIQuizService openAI;

  final QuizLocalCacheService localCache;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;

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

  Future<void> saveCurrentAttempt({
    required String userId,
    required Map<String, dynamic> json,
  }) {
    return localCache.saveAttempt(
      userId: userId,
      json: json,
    );
  }

  Future<Map<String, dynamic>?> restoreCurrentAttempt({
    required String userId,
  }) async {
    return await localCache.loadCurrentAttempt(
      userId: userId,
    );
  }

  Future<void> clearCurrentAttempt({
    required String userId,
  }) {
    return localCache.clearCurrentAttempt(
      userId: userId,
    );
  }

  Future<QuizAttempt?> restoreQuizAttempt({
    required String userId,
    required QuizResponse quiz,
  }) async {
    final json = await restoreCurrentAttempt(
      userId: userId,
    );

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

  Future<void> saveAttemptToCloud({
    required String userId,
    required QuizAttempt attempt,
  }) async {
    await _database
        .collection('users')
        .doc(userId)
        .collection('quizzes')
        .doc(attempt.id)
        .set(
          attempt.toJson(),
        );
  }
}
