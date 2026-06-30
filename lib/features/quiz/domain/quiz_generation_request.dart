import 'question_type.dart';
import 'quiz_difficulty.dart';

class QuizGenerationRequest {
  const QuizGenerationRequest({
    required this.studyContext,
    required this.questionCount,
    required this.difficulty,
    required this.questionTypes,
    required this.extraInstructions,
  });

  final String studyContext;

  final int questionCount;

  final QuizDifficulty difficulty;

  final List<QuestionType> questionTypes;

  final String extraInstructions;
}