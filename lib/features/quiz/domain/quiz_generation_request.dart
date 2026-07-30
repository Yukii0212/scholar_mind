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
    this.avoidedQuestionsText = '',
  });

  final String studyContext;

  /// Formatted text describing questions the user previously marked "Not
  /// Important" (see QuizFeedbackEntry/QuizFeedbackRepository), so the
  /// generator can steer away from similar ones. Empty if the user has no
  /// flagged questions, or none could be fetched.
  final String avoidedQuestionsText;

  final int questionCount;

  final AssessmentMode assessmentMode;

  final QuizDifficulty difficulty;

  final BloomsLevel minimumBloomsLevel;

  final BloomsLevel maximumBloomsLevel;

  final List<QuestionType> questionTypes;

  final String extraInstructions;

  final QuestionTypeWeight questionTypeWeight;
}