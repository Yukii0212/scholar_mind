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

Content Guidance

Prioritize the core concepts, definitions, and relationships a student
needs to understand the material or do well on an exam.
Avoid testing trivial or incidental details (e.g. a number used only in
a one-off example) unless that detail is itself the concept being taught.

Extra Instructions

${extraInstructions.length >= 5 ? extraInstructions : 'None.'}

${request.avoidedQuestionsText.trim().isEmpty ? '' : '''
Previously Flagged As Not Important

The user has marked the following past questions as "Not Important" from
earlier quizzes. Do not ask these questions again, and avoid generating
near-duplicates or questions that test the exact same narrow fact. Where
a reason is given, treat it as an explicit content preference and respect
it for this generation too (e.g. if flagged as "off-syllabus", avoid that
whole topic; if "too trivial", prefer a deeper question on the same
concept instead of skipping it entirely).

${request.avoidedQuestionsText.trim()}
'''}

Return ONLY valid JSON.

{
  "title":"Short descriptive quiz title",

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

Quiz Title Rules
- Generate a concise title between 3 and 8 words.
- Summarize the overall topic being assessed.
- Do not include timestamps.
- Do not include words like "Generated Quiz".
- Do not include "Practice" unless appropriate.
- Examples:
  - TCP Congestion Control
  - Database Normalization
  - Binary Search Trees
  - Object-Oriented Programming
''';
  }
}