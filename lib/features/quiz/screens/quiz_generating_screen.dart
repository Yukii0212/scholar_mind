import 'package:flutter/material.dart';

import '../domain/quiz_generation_request.dart';
import '../domain/quiz_response.dart';
import '../services/openai_quiz_service.dart';
import 'quiz_viewer_screen.dart';

class QuizGeneratingScreen extends StatefulWidget {
  const QuizGeneratingScreen({
    super.key,
    required this.request,
  });

  final QuizGenerationRequest request;

  @override
  State<QuizGeneratingScreen> createState() =>
      _QuizGeneratingScreenState();
}

class _QuizGeneratingScreenState
    extends State<QuizGeneratingScreen> {

  final _openAIQuizService =
  const OpenAIQuizService();

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  Future<void> _generateQuiz() async {
    try {
      final result = await Future.wait([
        _openAIQuizService.generateQuiz(
          studyContext: widget.request.studyContext,
          instructions: '''
Generate UP TO ${widget.request.questionCount} questions.

Difficulty: ${widget.request.difficulty.toPrompt()}.

Question Types:
${widget.request.questionTypes.map((e) => '- ${e.toJson()}').join('\n')}

Extra Instructions:
${widget.request.extraInstructions.isEmpty ? 'None.' : widget.request.extraInstructions}

Return ONLY valid JSON.

Schema:

{
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
    }
  ]
}
''',
        ),
        Future.delayed(
          const Duration(seconds: 1),
        ),
      ]);

      if (!mounted) return;

      final quiz =
      result.first as QuizResponse;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              QuizViewerScreen(
                quiz: quiz,
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Generating Quiz',
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),

                SizedBox(height: 32),

                Text(
                  'Generating your AI quiz...',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  'ScholarMind is reading '
                      'your study materials '
                      'and creating questions.',
                  textAlign:
                  TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}