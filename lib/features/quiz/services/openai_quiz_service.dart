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
PRIORITY ORDER
==========================

When sources conflict, resolve them in this order:

1. The user's Extra Instructions (in INSTRUCTIONS above) — these are an
   explicit, deliberate request. Follow them even if they push against the
   defaults below.
2. The Past Year Questions section, if present.
3. Lecture Notes.
4. General knowledge of the subject.

==========================
QUESTION STYLE
==========================

If past-year papers are provided:

Treat them as the primary reference for, and ONLY for:
- structure (how a question is put together)
- phrasing conventions and command verbs (e.g. "Identify", "Compare",
  "Justify", "Construct a table")
- lecturer expectations (how much detail, what "done well" looks like)
- difficulty
- topic scope — every generated question should fall within the subject
  areas the past-year paper actually covers, not just the first few

Do NOT treat a past-year question's specific wording, scenario, or
example as something to reuse. A rewritten or lightly reworded version of
a past-year question is still a copy — it is NOT acceptable, even if
individual words are changed. Every generated question must be
independently writable by someone who only knows the concept, without
ever having seen the past-year paper. Test this by asking yourself: "if
I changed the numbers/scenario/subject of this question, would it still
obviously be the same past-year question?" — if yes, discard it and
write a genuinely different question about the same concept instead
(different angle: application to a new scenario, comparison, cause and
effect, a "what would happen if" variant, etc).

A single past-year paper is usually short relative to the number of
questions requested. Once you've covered the concepts it directly raises,
keep generating within the SAME topic scope using lecture notes for
supporting detail and NEW scenarios/angles for each question — do not
drift into unrelated topics the lecture notes cover but the past-year
paper does not.

If, after applying the anti-copying rule above, there genuinely isn't
enough distinct material to reach the requested question count without
duplicating or thinly rewording a past-year question, generate fewer
questions instead (see RULES, below) — a shorter quiz beats a padded one.

Use lecture notes primarily to determine WHAT concepts should be assessed,
constrained to topics the past-year paper (when provided) has established
as in-scope.

Generate NEW questions that imitate the lecturer's assessment style, not
the past-year paper's specific content.

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

2. If there is insufficient study material, generate fewer questions instead of inventing facts, repeating the same concept, or reusing/rewording a past-year question to hit the requested count.

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

{
  "title": "Database Normalization",

  "questions": [
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
    },
    {
      "type": "true_false",
      "question": "...",
      "options": [
        "True",
        "False"
      ],
      "correctAnswerIndex": 0,
      "explanation": "..."
    },
    {
      "type": "open_ended",
      "question": "...",
      "sampleAnswer": "...",
      "explanation": "..."
    }
  ]
}

Quiz Title Rules

- Generate a concise title between 3 and 8 words.
- The title should summarize the overall topic of the quiz.
- Do not include timestamps.
- Do not include "Generated Quiz".
- Do not include "Practice Quiz" unless it genuinely describes the quiz.
- Examples:
  - TCP Congestion Control
  - Binary Search Trees
  - Database Normalization
  - Object-Oriented Programming
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