import 'quiz_question.dart';

class QuizResponse {
  const QuizResponse({
    required this.title,
    required this.questions,
  });

  final String title;

  final List<QuizQuestion> questions;

  factory QuizResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return QuizResponse(
      title:
      json['title']
      as String? ??
          'Untitled Quiz',

      questions:
      (json['questions'] as List)
          .map(
            (question) =>
            QuizQuestion.fromJson(
              question
              as Map<String, dynamic>,
            ),
      )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'questions': questions
          .map((question) => question.toJson())
          .toList(),
    };
  }
}