import 'question_type.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  final QuestionType type;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
}