import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  const CourseModel({
    required this.id,
    required this.ownerId,
    required this.semesterId,
    required this.name,
    this.targetScore,
    this.minimumAcceptableScore,
    this.passingScore = 50,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  /// Empty for documents written before ownership tracking was added --
  /// not yet backfilled. See CourseRepository.backfillOwnership.
  final String ownerId;

  final String semesterId;

  final String name;

  /// Student's desired final percentage.
  final double? targetScore;

  /// Lowest percentage the student would personally
  /// be satisfied with.
  final double? minimumAcceptableScore;

  /// Lowest percentage required to pass.
  final double passingScore;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory CourseModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    return CourseModel(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      semesterId: data['semesterId'] as String,
      name: data['name'] as String,
      targetScore:
      (data['targetScore'] as num?)
          ?.toDouble(),

      minimumAcceptableScore:
      (data[
      'minimumAcceptableScore'
      ] as num?)
          ?.toDouble(),

      passingScore:
      (data['passingScore'] as num?)
          ?.toDouble() ??
          50,
      createdAt:
      (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
      (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'semesterId': semesterId,
      'name': name,
      'targetScore': targetScore,
      'minimumAcceptableScore':
      minimumAcceptableScore,
      'passingScore': passingScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CourseModel copyWith({
    String? id,
    String? ownerId,
    String? semesterId,
    String? name,
    double? targetScore,
    bool clearTargetScore = false,

    double? minimumAcceptableScore,
    bool clearMinimumAcceptableScore =
    false,

    double? passingScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      semesterId: semesterId ?? this.semesterId,
      name: name ?? this.name,
      targetScore:
      clearTargetScore
          ? null
          : targetScore ??
          this.targetScore,

      minimumAcceptableScore:
      clearMinimumAcceptableScore
          ? null
          : minimumAcceptableScore ??
          this
              .minimumAcceptableScore,

      passingScore:
      passingScore ??
          this.passingScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}