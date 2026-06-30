import 'package:flutter/material.dart';

import '../domain/question_type.dart';
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
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${question.question}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (question.type ==
                      QuestionType.multipleChoice)
                    ...List.generate(
                      question.options.length,
                          (optionIndex) => Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 8,
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${String.fromCharCode(
                                65 + optionIndex,
                              )}. ',
                            ),
                            Expanded(
                              child: Text(
                                question.options[
                                optionIndex],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}