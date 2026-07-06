import 'assessment_mode.dart';
import 'blooms_level.dart';
import 'question_type.dart';
import 'quiz_difficulty.dart';
import 'question_type_weight.dart';

class QuizGenerationRequest {
  const QuizGenerationRequest({
    required this.studyContext,
    required this.questionCount,
    required this.assessmentMode,
    required this.difficulty,
    required this.minimumBloomsLevel,
    required this.maximumBloomsLevel,
    required this.questionTypes,
    required this.extraInstructions,
    required this.questionTypeWeight,
  });

  final String studyContext;

  final int questionCount;

  final AssessmentMode assessmentMode;

  final QuizDifficulty difficulty;

  final BloomsLevel minimumBloomsLevel;

  final BloomsLevel maximumBloomsLevel;

  final List<QuestionType> questionTypes;

  final String extraInstructions;

  final QuestionTypeWeight questionTypeWeight;
}