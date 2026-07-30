import 'package:cloud_firestore/cloud_firestore.dart';

/// A question the user flagged as "Not important" from a completed quiz --
/// kept so they can review/manage what they've flagged, and so future
/// generations can be steered away from similar questions. Scoped per user
/// only (this app has no course/topic linkage on quiz questions to scope
/// it any tighter than that).
class QuizFeedbackEntry {
  const QuizFeedbackEntry({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.createdAt,
    this.reason,
  });

  final String id;
  final String questionText;

  /// The raw QuestionType name (e.g. 'multiple_choice') -- kept as a plain
  /// string here since it's only ever used for prompt context and display,
  /// never branched on.
  final String questionType;

  final String? reason;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'questionType': questionType,
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory QuizFeedbackEntry.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return QuizFeedbackEntry(
      id: document.id,
      questionText: data['questionText'] as String,
      questionType: data['questionType'] as String,
      reason: data['reason'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
