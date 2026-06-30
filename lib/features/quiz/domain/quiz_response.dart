import 'quiz_question.dart';

class QuizResponse {
  const QuizResponse({
    required this.questions,
  });

  final List<QuizQuestion> questions;

  factory QuizResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return QuizResponse(
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
}