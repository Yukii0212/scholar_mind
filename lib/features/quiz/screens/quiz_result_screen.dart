import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/quiz_attempt_provider.dart';

import '../domain/question_type.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_response.dart';

class QuizResultScreen
    extends ConsumerStatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.answers,
  });

  final QuizResponse quiz;
  final Map<int, QuizAnswer> answers;

  @override
  ConsumerState<QuizResultScreen>
  createState() =>
      _QuizResultScreenState();
}

class _QuizResultScreenState
    extends ConsumerState<QuizResultScreen> {

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

    final attempt =
    ref.watch(
      quizAttemptProvider,
    );

    final answers =
        attempt?.answers ??
            widget.answers;

    final total =
        widget.quiz.questions.length;

    final objectiveTotal =
        widget.quiz.questions
            .where(
              (question) =>
          question.type !=
              QuestionType.openEnded,
        )
            .length;

    var correct = 0;

    for (var i = 0; i < total; i++) {
      final answer =
      answers[i];

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
    objectiveTotal == 0
        ? null
        : ((correct /
        objectiveTotal) *
        100)
        .round();

    final openEndedCount =
        widget.quiz.questions
            .where(
              (question) =>
          question.type ==
              QuestionType.openEnded,
        )
            .length;

    final pendingReview =
    answers.values.any(
          (answer) => answer.aiReviewPending,
    );

    var essayScore = 0;
    var essayMax = 0;

    for (final answer in answers.values) {
      essayScore += answer.aiScore ?? 0;
      essayMax += answer.aiMaxScore ?? 0;
    }

    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Quiz Results'),
      ),
      body: ListView(
        padding:
        const EdgeInsets.all(20),
        children: [

          if (objectiveTotal > 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [

                    Text(
                      '$percentage%',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '$correct / $objectiveTotal Correct',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                  ],
                ),
              ),
            ),

          if (objectiveTotal > 0)
            const SizedBox(height: 20),

          const SizedBox(height: 20),

          if (openEndedCount > 0)
            Card(
              child: ListTile(
                leading: Icon(
                  pendingReview
                      ? Icons.hourglass_top
                      : Icons.auto_awesome,
                ),
                title: Text(
                  pendingReview
                      ? 'AI Review in Progress'
                      : 'Open-ended Review Complete',
                ),
                subtitle: Text(
                  pendingReview
                      ? 'Score: ? / $essayMax\n\nScholarMind is reviewing your answers.'
                      : 'Score: $essayScore / $essayMax',
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
              answers[index];

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

                      answer?.aiReviewPending ?? true
                          ? ListTile(
                        leading: const Icon(
                          Icons.hourglass_top,
                        ),
                        title: const Text(
                          'AI Review in Progress',
                        ),
                        subtitle: Text(
                          essayMax == 0
                              ? 'Preparing AI review...\n\nYour score will appear automatically.'
                              : 'Score: ? / $essayMax\n\nScholarMind is reviewing your answer.',
                        ),
                      )
                          : Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.auto_awesome,
                            ),
                            title: const Text(
                              'AI Score',
                            ),
                            subtitle: Text(
                              '${answer?.aiScore ?? 0} / ${answer?.aiMaxScore ?? 0}',
                            ),
                          ),

                          ListTile(
                            leading: const Icon(
                              Icons.person_outline,
                            ),
                            title: const Text(
                              'Your Answer',
                            ),
                            subtitle: SelectableText(
                              answer?.openEndedAnswer.isNotEmpty == true
                                  ? answer!.openEndedAnswer
                                  : 'No answer provided.',
                            ),
                          ),

                          ListTile(
                            leading: const Icon(
                              Icons.feedback_outlined,
                            ),
                            title: const Text(
                              'AI Feedback',
                            ),
                            subtitle: Text(
                              answer?.aiFeedback ??
                                  'No feedback available.',
                            ),
                          ),
                        ],
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