import 'quiz_answer.dart';
import 'quiz_response.dart';

enum QuizAttemptStatus {
  inProgress,
  submitted,
  completed,
}

class QuizAttempt {
  const QuizAttempt({
    required this.id,
    required this.quiz,
    required this.answers,
    required this.status,
    required this.startedAt,
    this.submittedAt,
    this.completedAt,
  });

  final String id;

  final QuizResponse quiz;

  final Map<int, QuizAnswer> answers;

  final QuizAttemptStatus status;

  final DateTime startedAt;

  final DateTime? submittedAt;

  final DateTime? completedAt;
  QuizAttempt copyWith({
    Map<int, QuizAnswer>? answers,
    QuizAttemptStatus? status,
    DateTime? submittedAt,
    DateTime? completedAt,
  }) {
    return QuizAttempt(
      id: id,
      quiz: quiz,
      answers: answers ?? this.answers,
      status: status ?? this.status,
      startedAt: startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'startedAt':
      startedAt.toIso8601String(),
      'submittedAt':
      submittedAt
          ?.toIso8601String(),
      'completedAt':
      completedAt
          ?.toIso8601String(),
      'answers':
      answers.map(
            (key, value) => MapEntry(
          key.toString(),
          value.toJson(),
        ),
      ),
    };
  }

}