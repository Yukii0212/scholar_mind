import 'package:flutter/material.dart';

import '../domain/question_type.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_response.dart';
import 'quiz_result_screen.dart';
import '../services/openai_quiz_service.dart';

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

  final _openAIQuizService =
  const OpenAIQuizService();

// TODO:
// Remove after migration to
// QuizAttemptController.
  final Map<int, QuizAnswer> _answers = {};

  int get _answeredQuestions {
    var answered = 0;

    for (var i = 0;
    i < widget.quiz.questions.length;
    i++) {
      final answer = _answers[i];

      if (answer == null) {
        continue;
      }

      final question =
      widget.quiz.questions[i];

      switch (question.type) {
        case QuestionType.multipleChoice:
        case QuestionType.trueFalse:
          if (answer.selectedOptionIndex != null) {
            answered++;
          }
          break;

        case QuestionType.openEnded:
          if ((answer.openEndedAnswer ?? '')
              .trim()
              .isNotEmpty) {
            answered++;
          }
          break;
      }
    }

    return answered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Generated Quiz'),
      ),
      body: SafeArea(
        child: Column(
            children: [
        Expanded(
        child: ListView.builder(
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
                      'Review this question later',
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
                      'I was not confident in this answer',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        ),
        ),

              SafeArea(
                top: false,
                minimum: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    'Submit Quiz',
                  ),
                  onPressed: _submitQuiz,
                ),
              ),
            ],
        ),
      ),
    );
  }

  Future<void> _submitQuiz() async {
    final submit =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Submit Quiz?',
          ),
          content: Text(
            'You have answered '
                '$_answeredQuestions of '
                '${widget.quiz.questions.length} questions.\n\n'
                'You can still review your answers after submitting.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Submit',
              ),
            ),
          ],
        );
      },
    );

    if (submit != true) {
      return;
    }

    if (!mounted) {
      return;
    }
    final openEndedAnswers =
    <Map<String, String>>[];

    for (var i = 0;
    i < widget.quiz.questions.length;
    i++) {
      final question =
      widget.quiz.questions[i];

      if (question.type !=
          QuestionType.openEnded) {
        continue;
      }

      final answer =
      _answers[i];

      openEndedAnswers.add({
        'questionIndex':
        i.toString(),
        'question':
        question.question,
        'sampleAnswer':
        question.sampleAnswer ?? '',
        'studentAnswer':
        answer?.openEndedAnswer ?? '',
      });

      _answers[i] =
          (answer ??
              const QuizAnswer())
              .copyWith(
            aiReviewPending: true,
          );
    }

    if (openEndedAnswers.isNotEmpty) {
      _evaluateOpenEndedAnswers(
        openEndedAnswers,
      );
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          quiz: widget.quiz,
          answers: _answers,
        ),
      ),
    );
  }
  Future<void> _evaluateOpenEndedAnswers(
      List<Map<String, String>> answers,
      ) async {

    final results =
    await _openAIQuizService
        .evaluateOpenEndedAnswers(
      answers: answers,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      for (final result in results) {
        final index = int.parse(
          result['questionIndex']
              .toString(),
        );

        _answers[index] =
            (_answers[index] ??
                const QuizAnswer())
                .copyWith(
              aiReviewPending: false,
              aiScore:
              result['score'] as int?,
              aiMaxScore:
              result['maxScore']
              as int?,
              aiFeedback:
              result['feedback']
              as String?,
            );
      }
    });
  }
}