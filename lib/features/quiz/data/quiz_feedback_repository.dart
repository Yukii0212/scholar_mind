import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/quiz_feedback_entry.dart';

class QuizFeedbackRepository {
  QuizFeedbackRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _feedback(String userId) =>
      _firestore.collection('users').doc(userId).collection('quizFeedback');

  /// All flagged questions, newest first -- unbounded. Storage is cheap and
  /// the user asked to be able to see and manage everything they've ever
  /// flagged, not just a recent slice.
  Stream<List<QuizFeedbackEntry>> watchFeedback(String userId) {
    return _feedback(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(QuizFeedbackEntry.fromDocument)
              .toList(),
        );
  }

  Future<void> addFeedback({
    required String userId,
    required String questionText,
    required String questionType,
    String? reason,
  }) {
    return _feedback(userId).add({
      'questionText': questionText,
      'questionType': questionType,
      'reason': (reason == null || reason.trim().isEmpty)
          ? null
          : reason.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteFeedback({
    required String userId,
    required String feedbackId,
  }) {
    return _feedback(userId).doc(feedbackId).delete();
  }

  Future<void> clearAllFeedback(String userId) async {
    final snapshot = await _feedback(userId).get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Recent flagged questions, most-relevant-first, bounded for prompt use
  /// -- unlike [watchFeedback] this deliberately does NOT return everything
  /// the user has ever flagged, since that text gets pasted directly into
  /// the generation prompt and an unbounded list would blow out prompt size
  /// for a long-time user without meaningfully improving results.
  Future<List<QuizFeedbackEntry>> recentFeedbackForPrompt(
    String userId, {
    int limit = 40,
  }) async {
    final snapshot = await _feedback(userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map(QuizFeedbackEntry.fromDocument).toList();
  }

  /// Formats entries (as returned by [recentFeedbackForPrompt]) into the
  /// text block QuizPromptBuilder embeds in the generation prompt.
  static String formatForPrompt(List<QuizFeedbackEntry> entries) {
    if (entries.isEmpty) return '';

    final buffer = StringBuffer();

    for (final entry in entries) {
      buffer.write('- "${entry.questionText}"');

      if (entry.reason != null && entry.reason!.isNotEmpty) {
        buffer.write(' (Reason: ${entry.reason})');
      }

      buffer.writeln();
    }

    return buffer.toString().trim();
  }
}
