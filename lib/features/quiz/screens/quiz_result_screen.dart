import 'package:flutter/material.dart';

import '../domain/question_type.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_response.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.answers,
  });

  final QuizResponse quiz;
  final Map<int, QuizAnswer> answers;

  @override
  State<QuizResultScreen> createState() =>
      _QuizResultScreenState();
}

class _QuizResultScreenState
    extends State<QuizResultScreen> {

  late final List<bool> _expanded;

  @override
  void initState() {
    super.initState();

    _expanded = List.generate(
      widget.quiz.questions.length,
          (index) {
        final answer =
        widget.answers[index];

        if (answer == null) {
          return false;
        }

        if (answer.markedForReview) {
          return true;
        }

        if (answer.guessed) {
          return true;
        }

        final question =
        widget.quiz.questions[index];

        switch (question.type) {
          case QuestionType.multipleChoice:
          case QuestionType.trueFalse:
            return answer
                .selectedOptionIndex !=
                question.correctAnswerIndex;

          case QuestionType.openEnded:
            return true;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final total =
        widget.quiz.questions.length;

    var correct = 0;

    for (var i = 0; i < total; i++) {
      final answer =
      widget.answers[i];

      if (answer == null) {
        continue;
      }

      final question =
      widget.quiz.questions[i];

      if (question.type ==
          QuestionType.openEnded) {
        continue;
      }

      if (question.correctAnswerIndex != null &&
          answer.selectedOptionIndex ==
              question.correctAnswerIndex) {
        correct++;
      }
    }

    final percentage =
    total == 0
        ? 0
        : ((correct / total) * 100)
        .round();

    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Quiz Results'),
      ),
      body: ListView(
        padding:
        const EdgeInsets.all(20),
        children: [

          Card(
            child: Padding(
              padding:
              const EdgeInsets.all(
                24,
              ),
              child: Column(
                children: [

                  Text(
                    '$percentage%',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    '$correct / $total Correct',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          ...List.generate(
            total,
                (index) {
              final question =
              widget.quiz.questions[
              index];

              final answer =
              widget.answers[index];

              final correctAnswer =
                  question.correctAnswerIndex != null &&
                      answer?.selectedOptionIndex ==
                          question.correctAnswerIndex;

              return Card(
                margin:
                const EdgeInsets.only(
                  bottom: 16,
                ),
                child:
                ExpansionTile(
                  initiallyExpanded:
                  _expanded[index],

                  leading: question.type ==
                      QuestionType
                          .openEnded
                      ? const Icon(
                    Icons
                        .hourglass_top,
                  )
                      : Icon(
                    correctAnswer
                        ? Icons
                        .check_circle
                        : Icons
                        .cancel,
                  ),

                  title: Text(
                    'Question ${index + 1}',
                  ),

                  subtitle:
                  Text(question.question),

                  children: [

                    if (question.type !=
                        QuestionType
                            .openEnded) ...[

                      ListTile(
                        title: const Text(
                          'Your Answer',
                        ),
                        subtitle: Text(
                          answer
                              ?.selectedOptionIndex ==
                              null
                              ? 'Not Answered'
                              : question.options[
                          answer!
                              .selectedOptionIndex!],
                        ),
                      ),

                      ListTile(
                        title: const Text(
                          'Correct Answer',
                        ),
                        subtitle: Text(
                          question.options[
                          question.correctAnswerIndex!
                          ],
                        ),
                      ),

                      ListTile(
                        title: const Text(
                          'Explanation',
                        ),
                        subtitle: Text(
                          question
                              .explanation,
                        ),
                      ),
                    ],

                    if (question.type ==
                        QuestionType
                            .openEnded)

                      const ListTile(
                        leading: Icon(
                          Icons
                              .hourglass_top,
                        ),
                        title: Text(
                          'Pending AI Review',
                        ),
                        subtitle: Text(
                          'ScholarMind is evaluating your answer.\n\n'
                              'Your feedback will appear here shortly.',
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}