import 'package:cloud_firestore/cloud_firestore.dart';

class SemesterModel {
  const SemesterModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
    required this.isManuallyEdited,
    required this.isHidden,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;

  final DateTime startDate;
  final DateTime endDate;

  final DateTime createdAt;
  final DateTime updatedAt;

  final bool isCurrent;
  final bool isManuallyEdited;
  final bool isHidden;

  factory SemesterModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    return SemesterModel(
      id: doc.id,
      name: data['name'] as String,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      isCurrent: data['isCurrent'] as bool? ?? false,
      isManuallyEdited:
      data['isManuallyEdited'] as bool? ?? false,
      isHidden:
      data['isHidden'] as bool? ?? false,
      createdAt:
      (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
      (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isCurrent': isCurrent,
      'isManuallyEdited': isManuallyEdited,
      'isHidden': isHidden,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SemesterModel copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    bool? isManuallyEdited,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SemesterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      isManuallyEdited:
      isManuallyEdited ?? this.isManuallyEdited,
      isHidden:
      isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}