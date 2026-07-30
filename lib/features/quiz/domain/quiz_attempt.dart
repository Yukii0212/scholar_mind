import 'package:cloud_firestore/cloud_firestore.dart';
import 'question_type.dart';
import 'quiz_answer.dart';
import 'quiz_response.dart';

enum QuizAttemptStatus {
  inProgress,
  grading,
  completed,
  archived,
}

class QuizAttempt {
  const QuizAttempt({
    required this.id,
    required this.quiz,
    required this.answers,
    required this.status,
    required this.startedAt,
    required this.name,
    required this.folderId,
    required this.createdAt,
    required this.updatedAt,

    this.submittedAt,
    this.completedAt,

    this.isFavorite = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  final String id;

  final QuizResponse quiz;

  final Map<int, QuizAnswer> answers;

  final QuizAttemptStatus status;

  final DateTime startedAt;

  final String name;

  final String folderId;

  final DateTime createdAt;

  final DateTime updatedAt;

  final DateTime? submittedAt;

  final DateTime? completedAt;

  final bool isFavorite;

  final bool isArchived;

  final bool isDeleted;

  final DateTime? deletedAt;

  /// How many questions have a genuinely meaningful answer -- NOT
  /// `answers.length`, which only reflects how many indices have ever been
  /// touched (an MC/TF selection or open-ended text that was later cleared
  /// still leaves its key in the map with a null/empty value). Mirrors
  /// QuizViewerScreen's own per-question "answered" check so the progress
  /// shown before opening a quiz (e.g. in the Resume list) matches what
  /// opening it actually shows.
  int get answeredCount {
    var answered = 0;

    for (var i = 0; i < quiz.questions.length; i++) {
      final answer = answers[i];

      if (answer == null) continue;

      switch (quiz.questions[i].type) {
        case QuestionType.multipleChoice:
        case QuestionType.trueFalse:
          if (answer.selectedOptionIndex != null) answered++;
        case QuestionType.openEnded:
          if (answer.openEndedAnswer.trim().isNotEmpty) answered++;
      }
    }

    return answered;
  }

  QuizAttempt copyWith({
    Map<int, QuizAnswer>? answers,
    QuizAttemptStatus? status,
    DateTime? submittedAt,
    DateTime? completedAt,

    String? name,
    String? folderId,
    DateTime? updatedAt,

    bool? isFavorite,
    bool? isArchived,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return QuizAttempt(
      id: id,
      quiz: quiz,
      answers: answers ?? this.answers,
      status: status ?? this.status,
      startedAt: startedAt,

      name: name ?? this.name,
      folderId: folderId ?? this.folderId,

      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,

      submittedAt: submittedAt ?? this.submittedAt,
      completedAt: completedAt ?? this.completedAt,

      isFavorite:
      isFavorite ?? this.isFavorite,

      isArchived:
      isArchived ?? this.isArchived,

      isDeleted:
      isDeleted ?? this.isDeleted,

      deletedAt:
      deletedAt ?? this.deletedAt,
    );
  }

  QuizAttempt reset() {

    final now = DateTime.now();

    return QuizAttempt(
      id: id,
      quiz: quiz,
      name: name,
      folderId: folderId,

      answers: const {},

      status: QuizAttemptStatus.inProgress,

      startedAt: now,

      createdAt: createdAt,

      updatedAt: now,

      submittedAt: null,

      completedAt: null,

      isFavorite: isFavorite,
      isArchived: isArchived,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
    );

  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'name': name,
      'folderId': folderId,

      'createdAt':
      createdAt.toIso8601String(),

      'updatedAt':
      updatedAt.toIso8601String(),

      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'isDeleted': isDeleted,

      'deletedAt':
      deletedAt?.toIso8601String(),

      'startedAt':
      startedAt.toIso8601String(),
      'submittedAt':
      submittedAt
          ?.toIso8601String(),
      'completedAt':
      completedAt
          ?.toIso8601String(),
      'quiz': quiz.toJson(),

      'answers':
      answers.map(
            (key, value) => MapEntry(
          key.toString(),
          value.toJson(),
        ),
      ),
    };
  }

  static DateTime? _readDate(dynamic value) {

    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.parse(value);
    }

    throw Exception(
      'Unsupported date type: ${value.runtimeType}',
    );

  }

  factory QuizAttempt.fromJson({
    QuizResponse? quiz,
    required Map<String, dynamic> json,
  }) {
    final rawAnswers =
    (json['answers'] as Map)
        .cast<String, dynamic>();

    final quizResponse = quiz ??
        (json['quiz'] == null
            ? const QuizResponse(
          title: 'Legacy Quiz',
          questions: [],
        )
            : QuizResponse.fromJson(
          Map<String, dynamic>.from(
            json['quiz'],
          ),
        ));

    return QuizAttempt(
      id: json['id'] as String,

      quiz: quizResponse,

      answers: rawAnswers.map(
            (key, value) => MapEntry(
          int.parse(key),
          QuizAnswer.fromJson(
            Map<String, dynamic>.from(value),
          ),
        ),
      ),

      status: QuizAttemptStatus.values.firstWhere(
            (element) => element.name == json['status'],
      ),

      startedAt: _readDate(
        json['startedAt'],
      )!,

      name: json['name'] as String,

      folderId: json['folderId'] as String,

      createdAt: _readDate(
        json['createdAt'],
      )!,

      updatedAt: _readDate(
        json['updatedAt'],
      )!,

      isFavorite: json['isFavorite'] ?? false,

      isArchived: json['isArchived'] ?? false,

      isDeleted: json['isDeleted'] ?? false,

      deletedAt: _readDate(
        json['deletedAt'],
      ),

      submittedAt: _readDate(
        json['submittedAt'],
      ),

      completedAt: _readDate(
        json['completedAt'],
      ),
    );
  }

  factory QuizAttempt.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data()!;

    return QuizAttempt.fromJson(
      json: data,
    );
  }
}