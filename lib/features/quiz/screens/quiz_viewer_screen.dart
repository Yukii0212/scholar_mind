import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/preferences/quiz_navigation_preferences.dart';
import '../providers/quiz_attempt_provider.dart';
import '../providers/quiz_feedback_provider.dart';

import '../domain/question_type.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_question.dart';
import '../domain/quiz_response.dart';
import 'quiz_navigation_preference_screen.dart';
import 'quiz_question_overview_screen.dart';
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
    extends ConsumerState<QuizViewerScreen>
    with WidgetsBindingObserver {

  QuizAttempt get attempt =>
      widget.attempt;

  QuizResponse get quiz =>
      attempt.quiz;

  final Map<int, TextEditingController>
  _openEndedControllers = {};

  final Map<int, FocusNode> _openEndedFocusNodes = {};

  final Map<int, GlobalKey> _questionKeys = {};

  bool _saving = false;

  QuizNavigationStyle? _navigationStyle;

  final PageController _pageController = PageController();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

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

      await _resolveNavigationStyle();
    });
  }

  Future<void> _resolveNavigationStyle() async {
    var style = await QuizNavigationPreferences.getStyle();

    if (style == null) {
      if (!mounted) return;

      style = await Navigator.of(context).push<QuizNavigationStyle>(
        MaterialPageRoute(
          builder: (_) => const QuizNavigationPreferenceScreen(),
          fullscreenDialog: true,
        ),
      );
    }

    if (!mounted) return;

    setState(() => _navigationStyle = style ?? QuizNavigationStyle.scroll);
  }

  void _jumpToQuestion(int index) {
    if (_navigationStyle == QuizNavigationStyle.swipe) {
      _pageController.jumpToPage(index);
      return;
    }

    final context = _questionKeys[index]?.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 250),
        alignment: 0.0,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The user can leave mid-quiz by backgrounding the app (home button,
    // app switcher, an incoming call) just as easily as by pressing back --
    // none of that triggers a Navigator pop, so PopScope alone would miss
    // it and leave up to 10s of answers unsaved (see _markDirty's timer).
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(quizAttemptProvider.notifier).saveNow();
    }
  }

  void _scrollQuestionIntoView(int index) {
    // Without this, focusing the answer field on a tall question leaves
    // only the text box visible once the keyboard opens -- the question
    // itself has already scrolled out of view. Delayed to run after the
    // keyboard's own resize animation, so the viewport height used for the
    // scroll calculation is the post-keyboard one, not the pre-keyboard one.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final context = _questionKeys[index]?.currentContext;

      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 250),
          alignment: 0.0,
        );
      }
    });
  }

  Future<void> _flagNotImportant(int index, QuizQuestion question) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mark as Not Important?'),
          content: Column(
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
                  hintText:
                      'e.g. too trivial, off-syllabus, already know this',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
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

    final reason = reasonController.text;
    reasonController.dispose();

    if (confirmed != true || !mounted) return;

    final answers = ref.read(quizAttemptProvider)?.answers ?? {};

    final updated = (answers[index] ?? const QuizAnswer()).copyWith(
      notImportant: true,
    );

    ref.read(quizAttemptProvider.notifier).updateAnswer(
          questionIndex: index,
          answer: updated,
        );

    await ref.read(quizFeedbackActionControllerProvider.notifier).flagQuestion(
          questionText: question.question,
          questionType: question.type.toJson(),
          reason: reason,
        );

    if (!mounted) return;

    setState(() {});
  }

  void _unflagNotImportant(int index) {
    final answers = ref.read(quizAttemptProvider)?.answers ?? {};

    final updated = (answers[index] ?? const QuizAnswer()).copyWith(
      notImportant: false,
    );

    ref.read(quizAttemptProvider.notifier).updateAnswer(
          questionIndex: index,
          answer: updated,
        );

    setState(() {});
  }

  int get _answeredQuestions =>
      ref.read(quizAttemptProvider)?.answeredCount ?? 0;

  @override
  Widget build(BuildContext context) {
    final currentAttempt =
    ref.watch(
      quizAttemptProvider,
    );

    if (currentAttempt == null || _navigationStyle == null) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );

    }

    final answers =
        currentAttempt.answers;

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          setState(() => _saving = true);

          // Block the pop until the save actually lands, rather than
          // firing it off unawaited alongside a pop that's already
          // underway -- otherwise the widget (and the ref it needs) can be
          // torn down before the save finishes.
          await ref
              .read(
            quizAttemptProvider.notifier,
          )
              .saveNow();

          if (!mounted) return;

          setState(() => _saving = false);

          Navigator.of(context).pop(result);
        },
        child: Scaffold(
      appBar: AppBar(
        title:
        const Text('Generated Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            tooltip: 'Question overview',
            onPressed: () async {
              final target = await Navigator.of(context).push<int>(
                MaterialPageRoute(
                  builder: (_) => QuizQuestionOverviewScreen(
                    quiz: quiz,
                    answers: answers,
                  ),
                ),
              );

              if (target == null || !mounted) return;

              _jumpToQuestion(target);
            },
          ),
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _navigationStyle == QuizNavigationStyle.swipe
            ? _buildSwipeBody(answers)
            : _buildScrollBody(answers),
      ),
        ),
    );
  }

  Widget _buildScrollBody(Map<int, QuizAnswer> answers) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: quiz.questions.length,
            itemBuilder: (context, index) =>
                _buildQuestionCard(context, index, answers),
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
            label: const Text('Submit Quiz'),
            onPressed: _submitQuiz,
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeBody(Map<int, QuizAnswer> answers) {
    final lastIndex = quiz.questions.length - 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / quiz.questions.length,
                  minHeight: 6,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Question ${_currentPage + 1} of ${quiz.questions.length}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: quiz.questions.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildQuestionCard(context, index, answers),
            ),
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    ),
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Back'),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _currentPage >= lastIndex
                    ? FilledButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Submit Quiz'),
                        onPressed: _submitQuiz,
                      )
                    : FilledButton.icon(
                        onPressed: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        ),
                        icon: const Icon(Icons.chevron_right_rounded),
                        label: const Text('Next'),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    int index,
    Map<int, QuizAnswer> answers,
  ) {
          final question =
          quiz.questions[index];

          final questionKey =
          _questionKeys.putIfAbsent(index, () => GlobalKey());

          return Card(
            key: questionKey,
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

                  if (question.type == QuestionType.openEnded) ...[
                    Builder(
                      builder: (context) {
                        final controller =
                        _openEndedControllers.putIfAbsent(
                          index,
                              () => TextEditingController(
                            text: answers[index]?.openEndedAnswer ?? '',
                          ),
                        );

                        final expectedText =
                            answers[index]?.openEndedAnswer ?? '';

                        if (controller.text != expectedText) {
                          controller.value = TextEditingValue(
                            text: expectedText,
                            selection: TextSelection.collapsed(
                              offset: expectedText.length,
                            ),
                          );
                        }

                        final focusNode = _openEndedFocusNodes.putIfAbsent(
                          index,
                          () => FocusNode()
                            ..addListener(() {
                              if (_openEndedFocusNodes[index]?.hasFocus ==
                                  true) {
                                _scrollQuestionIntoView(index);
                              }
                            }),
                        );

                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          // Bounded rather than unbounded (was
                          // minLines: 4, maxLines: null) — an ever-growing
                          // field is what pushes the question off-screen
                          // as the user types; capped, it scrolls
                          // internally instead, so the question above it
                          // stays put.
                          minLines: 3,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your answer...',
                          ),
                          onChanged: (value) {
                            final updated =
                            (answers[index] ?? const QuizAnswer())
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
                        );
                      },
                    ),
                  ],

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

                  CheckboxListTile(
                    contentPadding:
                    EdgeInsets.zero,
                    value:
                    answers[index]
                        ?.notImportant ??
                        false,
                    onChanged: (value) {
                      if (value == true) {
                        _flagNotImportant(index, question);
                      } else {
                        _unflagNotImportant(index);
                      }
                    },
                    title: const Text(
                      'Not important (exclude from grading)',
                    ),
                    secondary: const Icon(Icons.flag_outlined),
                  ),
                ],
              ),
            ),
          );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    for (final controller
    in _openEndedControllers.values) {
      controller.dispose();
    }

    for (final focusNode in _openEndedFocusNodes.values) {
      focusNode.dispose();
    }

    _pageController.dispose();

    super.dispose();
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