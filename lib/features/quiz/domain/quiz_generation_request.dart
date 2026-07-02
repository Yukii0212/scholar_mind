import 'question_type.dart';
import 'quiz_difficulty.dart';
import 'question_type_weight.dart';

class QuizGenerationRequest {
  const QuizGenerationRequest({
    required this.studyContext,
    required this.questionCount,
    required this.difficulty,
    required this.questionTypes,
    required this.extraInstructions,
    required this.questionTypeWeight,
  });

  final String studyContext;

  final int questionCount;

  final QuizDifficulty difficulty;

  final List<QuestionType> questionTypes;

  final String extraInstructions;

  final QuestionTypeWeight
  questionTypeWeight;
}