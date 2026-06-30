import 'question_type.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.sampleAnswer,
    required this.explanation,
  });

  final QuestionType type;

  final String question;

  final List<String> options;

  final int? correctAnswerIndex;

  final String? sampleAnswer;

  final String explanation;

  factory QuizQuestion.fromJson(
      Map<String, dynamic> json,
      ) {
    return QuizQuestion(
      type: QuestionType.fromJson(
        json['type'] as String,
      ),

      question:
      json['question'] as String,

      options:
      List<String>.from(
        (json['options'] as List?) ??
            [],
      ),

      correctAnswerIndex:
      json['correctAnswerIndex']
      as int?,

      sampleAnswer:
      json['sampleAnswer']
      as String?,

      explanation:
      json['explanation']
      as String,
    );
  }
}