import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openai_dart/openai_dart.dart';

import '../domain/quiz_response.dart';

class OpenAIQuizService {
  const OpenAIQuizService();

  Future<QuizResponse> generateQuiz({
    required String studyContext,
    required String instructions,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY not found.');
    }

    final client = OpenAIClient.withApiKey(apiKey);

    try {
      final prompt = '''
You are ScholarMind's AI Quiz Generator.

Your task is to generate high-quality quizzes from a student's study materials.

==========================
STUDY MATERIAL
==========================

$studyContext

==========================
INSTRUCTIONS
==========================

$instructions
==========================
QUESTION STYLE
==========================

If past-year papers are provided:

Treat them as the primary reference for:
- wording
- structure
- question style
- lecturer expectations
- difficulty

Use lecture notes primarily to determine WHAT concepts should be assessed.

Never copy past-year questions verbatim.

Generate NEW questions that imitate the lecturer's assessment style.

==========================
FORMATTING
==========================

Use blank lines generously.

Avoid long paragraphs.

If numerical data is provided, format it neatly.

If a scenario is required, make it easy to read.

Good formatting is part of the assessment quality.

==========================
RULES
==========================

1. Generate UP TO the requested number of questions.

2. If there is insufficient study material, generate fewer questions instead of inventing facts or repeating the same concept.

3. Every question MUST be answerable using ONLY the supplied study material.

4. Never invent information.

5. Every question must be completely standalone.

Never refer to:

- diagrams
- images
- figures
- tables
- screenshots
- page numbers
- slide numbers
- "the code above"
- "the figure below"
- "the comparison table"

Rewrite those references into the question itself.

6. Questions should primarily test understanding and application rather than simple memorization whenever possible.

Avoid asking questions that merely require recalling isolated facts if a deeper conceptual question can be asked instead.

7. Every explanation must teach the concept.

Do NOT mention:

- the notes
- the study material
- the lecture slides

Never say things like:

"The notes state..."
"The study material says..."

Instead explain WHY the correct answer is correct as if teaching a student who answered incorrectly.

Keep explanations between 2 and 4 sentences.

8. The selected question types are STRICT requirements.

Difficulty must change.
Question type must NOT.
Never generate question types that the user did not request.

Never substitute one question type for another.

9. Return ONLY valid JSON.

Do not include markdown.

Do not include ```json.

Do not include any explanation outside the JSON.

The response must be directly parseable using jsonDecode().

==========================
JSON FORMAT
==========================

[
  {
    "type": "multiple_choice",
    "question": "...",
    "options": [
      "...",
      "...",
      "...",
      "..."
    ],
    "correctAnswerIndex": 0,
    "explanation": "..."
  }
]

{
  "type": "open_ended",
  "question": "...",
  "sampleAnswer": "...",
  "explanation": "..."
}
''';

      final response = await client.responses.create(
        CreateResponseRequest(
          model: 'gpt-5-mini',
          input: ResponseInput.text(prompt),
        ),
      );

      final decoded =
      jsonDecode(response.outputText);

      print(decoded.runtimeType);

      QuizResponse quizResponse;

      if (decoded is List) {
        quizResponse = QuizResponse.fromJson({
          'questions': decoded,
        });
      } else {
        quizResponse = QuizResponse.fromJson(
          decoded as Map<String, dynamic>,
        );
      }

      return quizResponse;
    } finally {
      client.close();
    }
  }
  Future<List<Map<String, dynamic>>> evaluateOpenEndedAnswers({
    required List<Map<String, String>> answers,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY not found.');
    }

    final client = OpenAIClient.withApiKey(apiKey);

    try {
      final prompt = '''
You are ScholarMind's AI Marker.

Evaluate each student's answer.

Return ONLY valid JSON.

Each item MUST contain:

[
  {
    "questionIndex": 0,
    "score": 4,
    "maxScore": 5,
    "feedback": "..."
  }
]

Questions:

${jsonEncode(answers)}
''';

      final response =
      await client.responses.create(
        CreateResponseRequest(
          model: 'gpt-5-mini',
          input: ResponseInput.text(prompt),
        ),
      );

      final decoded =
      jsonDecode(response.outputText);

      return List<Map<String, dynamic>>.from(
        decoded,
      );
    } finally {
      client.close();
    }
  }
}