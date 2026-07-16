import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/quiz_attempt_provider.dart';

import '../domain/question_type.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_response.dart';
import 'quiz_result_screen.dart';
import '../domain/quiz_attempt.dart';

class QuizViewerScreen
    extends ConsumerStatefulWidget {
  const QuizViewerScreen({
    super.key,
    required this.attempt,
  });

  final QuizAttempt attempt;

  @override
  ConsumerState<QuizViewerScreen>
  createState() =>
      _QuizViewerScreenState();
}

class _QuizViewerScreenState
    extends ConsumerState<QuizViewerScreen> {

  QuizAttempt get attempt =>
      widget.attempt;

  QuizResponse get quiz =>
      attempt.quiz;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      await ref
          .read(
        quizAttemptProvider.notifier,
      )
          .restoreAttempt(
        attempt: widget.attempt,
      );
    });
  }

  int get _answeredQuestions {
    var answered = 0;

    for (var i = 0;
    i < quiz.questions.length;
    i++) {
      final answer =
      ref
          .read(
        quizAttemptProvider,
      )
          ?.answers[i];

      if (answer == null) {
        continue;
      }

      final question =
      quiz.questions[i];

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
    final currentAttempt =
    ref.watch(
      quizAttemptProvider,
    );

    if (currentAttempt == null) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );

    }

    final answers =
        currentAttempt.answers;

    return PopScope(
        onPopInvokedWithResult: (_, __) async {
          await ref
              .read(
            quizAttemptProvider.notifier,
          )
              .saveNow();
        },
        child: Scaffold(
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
        quiz.questions.length,
        itemBuilder:
            (context, index) {
          final question =
          quiz.questions[index];

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
                            answers[index]
                                ?.selectedOptionIndex,
                            title: Text(
                              question.options[
                              optionIndex],
                            ),
                            onChanged: (value) {
                              final updated =
                              (answers[index] ??
                                  const QuizAnswer())
                                  .copyWith(
                                selectedOptionIndex: value!,
                              );

                              

                              ref
                                  .read(
                                quizAttemptProvider.notifier,
                              )
                                  .updateAnswer(
                                questionIndex: index,
                                answer: updated,
                              );

                              setState(() {});
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
                        answers[index]
                            ?.selectedOptionIndex,
                        title: const Text(
                          'True',
                        ),
                        onChanged: (value) {
                          final updated =
                          (answers[index] ??
                              const QuizAnswer())
                              .copyWith(
                            selectedOptionIndex: value!,
                          );

                          ref
                              .read(
                            quizAttemptProvider.notifier,
                          )
                              .updateAnswer(
                            questionIndex: index,
                            answer: updated,
                          );

                          setState(() {});
                        },
                      ),
                      RadioListTile<int>(
                        value: 1,
                        groupValue:
                        answers[index]
                            ?.selectedOptionIndex,
                        title: const Text(
                          'False',
                        ),
                        onChanged: (value) {
                          final updated =
                          (answers[index] ??
                              const QuizAnswer())
                              .copyWith(
                            selectedOptionIndex: value!,
                          );

                          

                          ref
                              .read(
                            quizAttemptProvider.notifier,
                          )
                              .updateAnswer(
                            questionIndex: index,
                            answer: updated,
                          );

                          setState(() {});
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
                        answers[index]
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
                        final updated =
                        (answers[index] ??
                            const QuizAnswer())
                            .copyWith(
                          openEndedAnswer: value,
                        );

                        

                        ref
                            .read(
                          quizAttemptProvider.notifier,
                        )
                            .updateAnswer(
                          questionIndex: index,
                          answer: updated,
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
                    answers[index]
                        ?.markedForReview ??
                        false,
                    onChanged: (value) {
                      final updated =
                      (answers[index] ??
                          const QuizAnswer())
                          .copyWith(
                        markedForReview: value!,
                      );

                      

                      ref
                          .read(
                        quizAttemptProvider.notifier,
                      )
                          .updateAnswer(
                        questionIndex: index,
                        answer: updated,
                      );

                      setState(() {});
                    },
                    title: const Text(
                      'Review this question later',
                    ),
                  ),

                  CheckboxListTile(
                    contentPadding:
                    EdgeInsets.zero,
                    value:
                    answers[index]
                        ?.guessed ??
                        false,
                    onChanged: (value) {
                      final updated =
                      (answers[index] ??
                          const QuizAnswer())
                          .copyWith(
                        guessed: value!,
                      );

                      

                      ref
                          .read(
                        quizAttemptProvider.notifier,
                      )
                          .updateAnswer(
                        questionIndex: index,
                        answer: updated,
                      );

                      setState(() {});
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
                '${quiz.questions.length} questions.\n\n'
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

    await ref
        .read(
      quizAttemptProvider.notifier,
    )
        .startGrading();

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          quiz: quiz,
          answers: ref.read(
            quizAttemptProvider,
          )!.answers,
        ),
      ),
    );
  }
}