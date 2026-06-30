import 'quiz_question.dart';

class QuizResponse {
  const QuizResponse({
    required this.questions,
  });

  final List<QuizQuestion> questions;
}