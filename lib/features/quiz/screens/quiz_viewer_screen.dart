import 'package:flutter/material.dart';

import '../domain/question_type.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_response.dart';

class QuizViewerScreen extends StatefulWidget {
  const QuizViewerScreen({
    super.key,
    required this.quiz,
  });

  final QuizResponse quiz;

  @override
  State<QuizViewerScreen> createState() =>
      _QuizViewerScreenState();
}

class _QuizViewerScreenState
    extends State<QuizViewerScreen> {

  final Map<int, QuizAnswer> _answers = {};

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
        widget.quiz.questions.length,
        itemBuilder:
            (context, index) {
          final question =
          widget.quiz.questions[index];

          return Card(
            margin:
            const EdgeInsets.only(
              bottom: 20,
            ),
            child: Padding(
              padding:
              const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    'Question ${index + 1}',
                    style:
                    Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    question.question,
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  if (question.type ==
                      QuestionType
                          .multipleChoice)
                    ...List.generate(
                      question.options
                          .length,
                          (optionIndex) =>
                          RadioListTile<
                              int>(
                            value:
                            optionIndex,
                            groupValue:
                            _answers[index]
                                ?.selectedOptionIndex,
                            title: Text(
                              question.options[
                              optionIndex],
                            ),
                            onChanged: (value) {
                              setState(() {
                                _answers[index] =
                                    (_answers[index] ??
                                        const QuizAnswer())
                                        .copyWith(
                                      selectedOptionIndex: value!,
                                    );
                              });
                            },
                          ),
                    ),

                  if (question.type ==
                      QuestionType
                          .trueFalse)
                    ...[
                      RadioListTile<int>(
                        value: 0,
                        groupValue:
                        _answers[index]
                            ?.selectedOptionIndex,
                        title: const Text(
                          'True',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _answers[index] =
                                (_answers[index] ??
                                    const QuizAnswer())
                                    .copyWith(
                                  selectedOptionIndex: value!,
                                );
                          });
                        },
                      ),
                      RadioListTile<int>(
                        value: 1,
                        groupValue:
                        _answers[index]
                            ?.selectedOptionIndex,
                        title: const Text(
                          'False',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _answers[index] =
                                (_answers[index] ??
                                    const QuizAnswer())
                                    .copyWith(
                                  selectedOptionIndex: value!,
                                );
                          });
                        },
                      ),
                    ],

                  if (question.type ==
                      QuestionType
                          .openEnded)
                    TextField(
                      controller:
                      TextEditingController(
                        text:
                        _answers[index]
                            ?.openEndedAnswer ??
                            '',
                      ),
                      decoration:
                      const InputDecoration(
                        border:
                        OutlineInputBorder(),
                        hintText:
                        'Enter your answer...',
                      ),
                      onChanged: (value) {
                        _answers[index] =
                            (_answers[index] ??
                                const QuizAnswer())
                                .copyWith(
                              openEndedAnswer:
                              value,
                            );
                      },
                    ),

                  const SizedBox(
                    height: 12,
                  ),

                  CheckboxListTile(
                    contentPadding:
                    EdgeInsets.zero,
                    value:
                    _answers[index]
                        ?.markedForReview ??
                        false,
                    onChanged: (value) {
                      setState(() {
                        _answers[index] =
                            (_answers[index] ??
                                const QuizAnswer())
                                .copyWith(
                              markedForReview:
                              value!,
                            );
                      });
                    },
                    title: const Text(
                      'Mark for Review',
                    ),
                  ),

                  CheckboxListTile(
                    contentPadding:
                    EdgeInsets.zero,
                    value:
                    _answers[index]
                        ?.guessed ??
                        false,
                    onChanged: (value) {
                      setState(() {
                        _answers[index] =
                            (_answers[index] ??
                                const QuizAnswer())
                                .copyWith(
                              guessed: value!,
                            );
                      });
                    },
                    title: const Text(
                      'I guessed this answer',
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