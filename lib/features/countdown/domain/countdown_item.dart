import 'package:cloud_firestore/cloud_firestore.dart';

enum CountdownType {
  assignment,
  quiz,
  lab,
  presentation,
  project,
  midterm,
  finalExamination,
  personal,
  other,
}

extension CountdownTypeLabel on CountdownType {
  String get id => switch (this) {
        CountdownType.assignment => 'assignment',
        CountdownType.quiz => 'quiz',
        CountdownType.lab => 'lab',
        CountdownType.presentation => 'presentation',
        CountdownType.project => 'project',
        CountdownType.midterm => 'midterm',
        CountdownType.finalExamination => 'final_examination',
        CountdownType.personal => 'personal',
        CountdownType.other => 'other',
      };

  String get label => switch (this) {
        CountdownType.assignment => 'Assignment',
        CountdownType.quiz => 'Quiz',
        CountdownType.lab => 'Lab',
        CountdownType.presentation => 'Presentation',
        CountdownType.project => 'Project',
        CountdownType.midterm => 'Midterm',
        CountdownType.finalExamination => 'Final Exam',
        CountdownType.personal => 'Personal',
        CountdownType.other => 'Other',
      };

  static CountdownType fromId(String? id) {
    return CountdownType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => CountdownType.other,
    );
  }
}

class CountdownItem {
  const CountdownItem({
    required this.id,
    required this.title,
    required this.type,
    required this.priority,
    required this.dueDate,
    required this.description,
    required this.deadlineExtendable,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final CountdownType type;
  final int priority;
  final DateTime dueDate;
  final String? description;
  final bool deadlineExtendable;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get daysRemaining {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return end.difference(start).inDays;
  }

  factory CountdownItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return CountdownItem(
      id: doc.id,
      title: data['title'] as String,
      type: CountdownTypeLabel.fromId(data['type'] as String?),
      priority: data['priority'] as int? ?? 100,
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      description: data['description'] as String?,
      deadlineExtendable: data['deadlineExtendable'] as bool? ?? false,
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'type': type.id,
      'priority': priority,
      'dueDate': Timestamp.fromDate(dueDate),
      'description': description,
      'deadlineExtendable': deadlineExtendable,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CountdownItem copyWith({
    String? id,
    String? title,
    CountdownType? type,
    int? priority,
    DateTime? dueDate,
    String? description,
    bool? deadlineExtendable,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CountdownItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      deadlineExtendable: deadlineExtendable ?? this.deadlineExtendable,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
