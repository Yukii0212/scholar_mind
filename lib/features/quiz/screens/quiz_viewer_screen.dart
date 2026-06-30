import 'package:flutter/material.dart';

import '../domain/quiz_response.dart';

class QuizViewerScreen extends StatelessWidget {
  const QuizViewerScreen({
    super.key,
    required this.quiz,
  });

  final QuizResponse quiz;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Generated Quiz'),
      ),
      body: ListView.builder(
        padding:
        const EdgeInsets.all(20),
        itemCount:
        quiz.questions.length,
        itemBuilder:
            (context, index) {
          final question =
          quiz.questions[index];

          return Card(
            child: Padding(
              padding:
              const EdgeInsets.all(16),
              child: Text(
                '${index + 1}. '
                    '${question.question}',
              ),
            ),
          );
        },
      ),
    );
  }
}