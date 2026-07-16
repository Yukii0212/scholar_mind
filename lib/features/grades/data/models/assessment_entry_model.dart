import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/assessment/assessment_type.dart';
import '../../domain/assessment/score_interpretation.dart';

class AssessmentEntryModel {
  const AssessmentEntryModel({
    required this.id,
    required this.courseId,
    required this.componentId,
    required this.type,
    required this.score,
    required this.denominator,
    required this.percentage,
    required this.interpretation,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  final String courseId;

  final String componentId;

  final AssessmentType type;

  final double score;

  final double denominator;

  final double percentage;

  final ScoreInterpretation interpretation;

  final DateTime createdAt;

  final DateTime updatedAt;

  factory AssessmentEntryModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    return AssessmentEntryModel(
      id: doc.id,
      courseId: data['courseId'],
      componentId: data['componentId'],
      type: AssessmentType.values.byName(
        data['type'],
      ),
      score: (data['score'] as num).toDouble(),
      denominator:
      (data['denominator'] as num)
          .toDouble(),
      percentage:
      (data['percentage'] as num)
          .toDouble(),
      interpretation:
      ScoreInterpretation.values.byName(
        data['interpretation'],
      ),
      createdAt:
      (data['createdAt'] as Timestamp)
          .toDate(),
      updatedAt:
      (data['updatedAt'] as Timestamp)
          .toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'componentId': componentId,
      'type': type.name,
      'score': score,
      'denominator': denominator,
      'percentage': percentage,
      'interpretation':
      interpretation.name,
      'createdAt':
      Timestamp.fromDate(createdAt),
      'updatedAt':
      Timestamp.fromDate(updatedAt),
    };
  }

  AssessmentEntryModel copyWith({
    String? id,
    String? courseId,
    String? componentId,
    AssessmentType? type,
    double? score,
    double? denominator,
    double? percentage,
    ScoreInterpretation?
    interpretation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssessmentEntryModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      componentId:
      componentId ?? this.componentId,
      type: type ?? this.type,
      score: score ?? this.score,
      denominator:
      denominator ?? this.denominator,
      percentage:
      percentage ?? this.percentage,
      interpretation:
      interpretation ??
          this.interpretation,
      createdAt:
      createdAt ?? this.createdAt,
      updatedAt:
      updatedAt ?? this.updatedAt,
    );
  }
}