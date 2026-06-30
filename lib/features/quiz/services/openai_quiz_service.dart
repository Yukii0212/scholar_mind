import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openai_dart/openai_dart.dart';

class OpenAIQuizService {
  const OpenAIQuizService();

  Future<String> generateQuiz({
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

Study Material:

$studyContext

----------------------------------------

Instructions:

$instructions

Generate the quiz exactly as instructed.

Return the response as JSON only.

Do not wrap the JSON in markdown.
''';

      final response = await client.responses.create(
        CreateResponseRequest(
          model: 'gpt-5',
          input: ResponseInput.text(prompt),
        ),
      );

      return response.outputText;
    } finally {
      client.close();
    }
  }
}