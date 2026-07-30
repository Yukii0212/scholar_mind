import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart' hide ShareResult;

import '../../../core/app_tasks/domain/app_task_status.dart';
import '../../../core/app_tasks/domain/app_task_type.dart';
import '../../../core/app_tasks/providers/app_task_provider.dart';
import '../../../core/app_tasks/services/app_task_controller.dart';
import '../providers/quiz_attempt_provider.dart';

import '../domain/question_type.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_attempt.dart';
import '../domain/quiz_response.dart';
import '../providers/quiz_feedback_provider.dart';
import '../services/quiz_result_pdf_exporter.dart';

class QuizResultScreen
    extends ConsumerStatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.attempt,
  });

  final QuizAttempt attempt;

  @override
  ConsumerState<QuizResultScreen>
  createState() =>
      _QuizResultScreenState();
}

class _QuizResultScreenState
    extends ConsumerState<QuizResultScreen> {

  QuizResponse get quiz => widget.attempt.quiz;

  late final List<bool> _expanded;

  bool _exporting = false;

  Future<void> _flagNotImportant(int index, String questionText, QuestionType type) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mark as Not Important?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This question won\'t count toward your score, and future '
                  'quizzes will try to avoid asking similar ones.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  autofocus: true,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Why? (optional)',
                    hintText: 'e.g. too trivial, off-syllabus, already know this',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Mark'),
            ),
          ],
        );
      },
    );

    // Not disposed here -- see the identical dialog in
    // quiz_viewer_screen.dart for why (a still-animating dialog pop can
    // outlive this Future, and the TextField still references the
    // controller until it's actually unmounted).
    final reason = reasonController.text;

    if (confirmed != true || !mounted) return;

    final feedbackId = await ref
        .read(quizFeedbackActionControllerProvider.notifier)
        .flagQuestion(
          questionText: questionText,
          questionType: type.toJson(),
          reason: reason,
        );

    if (!mounted) return;

    final currentAnswers = ref.read(quizAttemptProvider)?.answers ?? widget.attempt.answers;

    final updated = (currentAnswers[index] ?? const QuizAnswer()).copyWith(
      notImportant: true,
      notImportantFeedbackId: feedbackId,
    );

    ref.read(quizAttemptProvider.notifier).updateAnswer(
          questionIndex: index,
          answer: updated,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marked as not important -- excluded from your score.')),
    );
  }

  Future<void> _unflagNotImportant(int index) async {
    final currentAnswers = ref.read(quizAttemptProvider)?.answers ?? widget.attempt.answers;
    final current = currentAnswers[index];

    final updated = (current ?? const QuizAnswer()).copyWith(
      notImportant: false,
      clearNotImportantFeedbackId: true,
    );

    ref.read(quizAttemptProvider.notifier).updateAnswer(
          questionIndex: index,
          answer: updated,
        );

    final feedbackId = current?.notImportantFeedbackId;

    if (feedbackId != null) {
      await ref
          .read(quizFeedbackActionControllerProvider.notifier)
          .deleteFeedback(feedbackId);
    }
  }

  Future<void> _exportPdf(
    QuizResponse quiz,
    Map<int, QuizAnswer> answers,
  ) async {
    setState(() => _exporting = true);

    try {
      final file = await const QuizResultPdfExporter().export(
        quiz: quiz,
        answers: answers,
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'My results for "${quiz.title}" on ScholarMind.',
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not export PDF: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _expanded = List.generate(
      quiz.questions.length,
          (index) {
        final answer =
        widget.attempt.answers[index];

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
        quiz.questions[index];

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

    WidgetsBinding.instance.addPostFrameCallback((_) => _resumeIfStuck());
  }

  // Reached directly from the Continue/Library list (not through
  // QuizViewerScreen's submit flow), this attempt may be sitting at
  // status: grading with open-ended answers still marked aiReviewPending
  // -- e.g. because the app was closed mid-review, abandoning the AI
  // evaluation Future entirely. Detect that and just resume grading,
  // rather than leaving the user staring at a permanently "in progress"
  // result.
  Future<void> _resumeIfStuck() async {
    if (!mounted) return;

    final notifier = ref.read(quizAttemptProvider.notifier);

    if (ref.read(quizAttemptProvider)?.id != widget.attempt.id) {
      await notifier.restoreAttempt(attempt: widget.attempt);
    }

    if (!mounted) return;

    final current = ref.read(quizAttemptProvider);

    final stuck = current != null &&
        current.status == QuizAttemptStatus.grading &&
        current.answers.values.any((answer) => answer.aiReviewPending);

    if (!stuck) return;

    final taskId = 'quiz_grading_${widget.attempt.id}';
    final existing = ref.read(appTaskProvider.notifier).taskById(taskId);

    // Already being graded (e.g. the submit flow just kicked this off and
    // the user tapped straight into results) -- don't fire a second,
    // redundant AI evaluation pass racing the first.
    if (existing != null &&
        existing.status != AppTaskStatus.completed &&
        existing.status != AppTaskStatus.failed) {
      return;
    }

    unawaited(
      ref.read(appTaskControllerProvider).run<void>(
        id: 'quiz_grading_${widget.attempt.id}',
        type: AppTaskType.quizGrading,
        title: 'Grading "${quiz.title}"',
        task: (progress) async {
          progress('Resuming AI review...');
          await notifier.startGrading();
        },
      ),
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
            widget.attempt.answers;

    final total =
        quiz.questions.length;

    var objectiveTotal = 0;
    var correct = 0;
    var openEndedCount = 0;
    var essayScore = 0;
    var essayMax = 0;

    for (var i = 0; i < total; i++) {
      final answer = answers[i];

      // Excluded from every count below -- see _flagNotImportant/
      // _unflagNotImportant.
      if (answer?.notImportant == true) {
        continue;
      }

      final question = quiz.questions[i];

      if (question.type == QuestionType.openEnded) {
        openEndedCount++;
        essayScore += answer?.aiScore ?? 0;
        essayMax += answer?.aiMaxScore ?? 0;
        continue;
      }

      objectiveTotal++;

      if (answer != null &&
          question.correctAnswerIndex != null &&
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

    final pendingReview =
    answers.values.any(
          (answer) =>
      !answer.notImportant &&
          answer.aiReviewPending,
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(

          onPressed: () {

            Navigator.popUntil(
              context,
                  (route) => route.isFirst,
            );

          },

        ),

        title: const Text(
          'Quiz Results',
        ),
        actions: [
          IconButton(
            icon: _exporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share_rounded),
            tooltip: 'Export as PDF',
            onPressed: _exporting
                ? null
                : () => _exportPdf(quiz, answers),
          ),
        ],
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
              quiz.questions[
              index];

              final answer =
              answers[index];

              final correctAnswer =
                  question.correctAnswerIndex != null &&
                      answer?.selectedOptionIndex ==
                          question.correctAnswerIndex;

              final excluded = answer?.notImportant == true;

              return Card(
                margin:
                const EdgeInsets.only(
                  bottom: 16,
                ),
                child:
                ExpansionTile(
                  initiallyExpanded:
                  _expanded[index],

                  leading: excluded
                      ? const Icon(Icons.flag_outlined)
                      : question.type ==
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
                    excluded
                        ? 'Question ${index + 1} (Excluded from grading)'
                        : 'Question ${index + 1}',
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

                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 4),
                        child: TextButton.icon(
                          onPressed: excluded
                              ? () => _unflagNotImportant(index)
                              : () => _flagNotImportant(
                                    index,
                                    question.question,
                                    question.type,
                                  ),
                          icon: Icon(
                            excluded
                                ? Icons.undo_rounded
                                : Icons.flag_outlined,
                            size: 18,
                          ),
                          label: Text(
                            excluded ? 'Include in Grading' : 'Not Important',
                          ),
                        ),
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