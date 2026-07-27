import 'package:cloud_firestore/cloud_firestore.dart';

class GradingComponentModel {
  const GradingComponentModel({
    required this.id,
    required this.ownerId,
    required this.courseId,
    required this.parentId,
    required this.name,
    required this.weight,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  /// Empty for documents written before ownership tracking was added --
  /// not yet backfilled. See CourseRepository.backfillOwnership.
  final String ownerId;

  final String courseId;
  final String? parentId;
  final String name;

  final double weight;

  final int order;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory GradingComponentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    return GradingComponentModel(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      courseId: data['courseId'] as String,
      parentId: data['parentId'] as String?,
      name: data['name'] as String,
      weight: (data['weight'] as num).toDouble(),
      order: data['order'] as int,
      createdAt:
      (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
      (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'courseId': courseId,
      'parentId': parentId,
      'name': name,
      'weight': weight,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  GradingComponentModel copyWith({
    String? id,
    String? ownerId,
    String? courseId,
    String? parentId,
    bool clearParentId = false,
    String? name,
    double? weight,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GradingComponentModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      courseId: courseId ?? this.courseId,
      parentId: clearParentId
          ? null
          : parentId ?? this.parentId,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}