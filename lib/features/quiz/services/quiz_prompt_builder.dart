import '../domain/question_type.dart';
import '../domain/quiz_generation_request.dart';

class QuizPromptBuilder {
  const QuizPromptBuilder();

  String build(
      QuizGenerationRequest request,
      ) {
    final extraInstructions =
    request.extraInstructions.trim();

    return '''
Generate UP TO ${request.questionCount} questions.

Difficulty: ${request.difficulty.toPrompt()}.

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