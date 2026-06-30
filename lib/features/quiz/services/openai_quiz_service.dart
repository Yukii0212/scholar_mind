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

6. Questions should test understanding rather than simple memorization whenever possible.

7. Keep explanations concise.

8. Return ONLY valid JSON.

Never return markdown.

Never return ```json.
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

      if (decoded is List) {
        return QuizResponse.fromJson({
          'questions': decoded,
        });
      }

      return QuizResponse.fromJson(
        decoded as Map<String, dynamic>,
      );
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