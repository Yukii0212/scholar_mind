import '../domain/question_type.dart';
import '../domain/quiz_generation_request.dart';
import '../domain/assessment_mode.dart';

class QuizPromptBuilder {
  const QuizPromptBuilder();

  String build(
      QuizGenerationRequest request,
      ) {
    final extraInstructions =
    request.extraInstructions.trim();

    return '''
Generate UP TO ${request.questionCount} questions.

${request.assessmentMode == AssessmentMode.informal
        ? '''
Assessment Style

Informal Practice

Difficulty: ${request.difficulty.toPrompt()}.
'''
        : '''
Assessment Style

Formal Assessment

Generate questions that assess Bloom's Cognitive Levels C${request.minimumBloomsLevel.level} through C${request.maximumBloomsLevel.level}.

Every question MUST primarily assess one cognitive level within this range.

Do not generate questions below C${request.minimumBloomsLevel.level}.

Do not generate questions above C${request.maximumBloomsLevel.level}.
'''}

ALLOWED QUESTION TYPES

${request.questionTypes.map((e) => '- ${e.toJson()}').join('\n')}

QUESTION TYPE WEIGHTING

- Multiple Choice: ${request.questionTypeWeight.multipleChoice}%
- True / False: ${request.questionTypeWeight.trueFalse}%
- Open Ended: ${request.questionTypeWeight.openEnded}%

The weighting is a target distribution.

If a question type is not selected,
its weighting MUST be treated as 0%.

Extra Instructions

${extraInstructions.length >= 5 ? extraInstructions : 'None.'}

Return ONLY valid JSON.

{
  "questions":[
    {
      "type":"multiple_choice",
      "question":"...",
      "options":["...","...","...","..."],
      "correctAnswerIndex":0,
      "explanation":"..."
    },
    {
      "type":"true_false",
      "question":"...",
      "options":["True","False"],
      "correctAnswerIndex":0,
      "explanation":"..."
    },
    {
      "type":"open_ended",
      "question":"...",
      "sampleAnswer":"...",
      "explanation":"..."
    }
  ]
}
''';
  }
}