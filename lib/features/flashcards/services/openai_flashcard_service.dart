import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openai_dart/openai_dart.dart';

import '../../quiz/domain/assessment_mode.dart';
import '../../quiz/domain/blooms_level.dart';
import '../../quiz/domain/quiz_difficulty.dart';
import '../domain/flashcard_models.dart';

class OpenAIFlashcardService {
  const OpenAIFlashcardService();

  Future<GeneratedFlashcardDeck> generateFlashcards({
    required String studyContext,
    required int cardCount,
    required AssessmentMode assessmentMode,
    required QuizDifficulty difficulty,
    required BloomsLevel minimumBloomsLevel,
    required BloomsLevel maximumBloomsLevel,
    required String extraInstructions,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY not found.');
    }

    final client = OpenAIClient.withApiKey(apiKey);

    try {
      final prompt = '''
You are ScholarMind's AI Flashcard Generator.

Generate high-quality study flashcards from the supplied material.

==========================
STUDY MATERIAL
==========================

$studyContext

==========================
INSTRUCTIONS
==========================

Generate UP TO $cardCount flashcards.

${assessmentMode == AssessmentMode.informal ? '''
Assessment Style

Informal Practice

Difficulty: ${difficulty.toPrompt()}.
''' : '''
Assessment Style

Formal Assessment

Generate flashcards that assess Bloom's Cognitive Levels C${minimumBloomsLevel.level} through C${maximumBloomsLevel.level}.

Every flashcard MUST primarily assess one cognitive level within this range -- a C1 card tests recall of a fact or definition, a C4 card might ask the student to compare or analyze, and so on.

Do not generate flashcards below C${minimumBloomsLevel.level}.

Do not generate flashcards above C${maximumBloomsLevel.level}.
'''}

Extra instructions: ${extraInstructions.trim().isEmpty ? 'None.' : extraInstructions.trim()}

Rules:
1. Every flashcard must be answerable using only the supplied study material.
2. Do not invent facts.
3. Only cover the core concepts, definitions, relationships, and facts a
   student would actually need to know for an exam or to understand the
   topic. Prioritize what an instructor would consider important.
4. Skip trivial, incidental, or one-off details (e.g. a specific number
   used only in an illustrative example, formatting artifacts, or an
   offhand aside) unless it is itself the concept being tested.
5. Keep the front concise and question-like.
6. Keep the back clear, useful, and teach the concept.
7. Use markdown where it improves readability.
8. Never reference page numbers, slide numbers, images, or "the notes".
9. Return ONLY valid JSON.

JSON format:

{
  "title": "Short Deck Title",
  "cards": [
    {
      "front": "Question or prompt",
      "back": "Answer or explanation",
      "tags": ["Networking"]
    }
  ]
}
''';

      final response = await client.responses.create(
        CreateResponseRequest(
          model: 'gpt-5-mini',
          input: ResponseInput.text(prompt),
        ),
      );

      final decoded = jsonDecode(response.outputText);
      return GeneratedFlashcardDeck.fromJson(
        Map<String, dynamic>.from(decoded as Map),
      );
    } finally {
      client.close();
    }
  }
}
