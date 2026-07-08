import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  const CourseModel({
    required this.id,
    required this.semesterId,
    required this.name,
    this.targetGrade,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  /// Null indicates this is a Personal Course.
  final String? semesterId;

  final String name;

  /// Student's personal target.
  final String? targetGrade;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory CourseModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    return CourseModel(
      id: doc.id,
      semesterId: data['semesterId'] as String?,
      name: data['name'] as String,
      targetGrade: data['targetGrade'] as String?,
      createdAt:
      (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
      (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'semesterId': semesterId,
      'name': name,
      'targetGrade': targetGrade,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CourseModel copyWith({
    String? id,
    String? semesterId,
    bool clearSemesterId = false,
    String? name,
    String? targetGrade,
    bool clearTargetGrade = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      semesterId: clearSemesterId
          ? null
          : semesterId ?? this.semesterId,
      name: name ?? this.name,
      targetGrade: clearTargetGrade
          ? null
          : targetGrade ?? this.targetGrade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}