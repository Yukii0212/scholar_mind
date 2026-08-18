import 'package:flutter/material.dart';

import '../../../core/theme/app_design.dart';
import '../../help/widgets/help_anchor.dart';
import '../../help/widgets/help_menu_button.dart';
import '../domain/question_type.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_response.dart';
import '../help/quiz_question_overview_help_topics.dart';

/// Lists every question with its current in-progress status (answered,
/// unanswered, marked as a guess, or flagged for review) and lets the
/// user jump straight to one. Calls [onSelectQuestion] directly (rather
/// than popping with a result for the caller to await) -- routing this
/// through Navigator.push<int>()'s result Future turned out not to
/// reliably deliver the tapped index back to the quiz screen; a plain
/// callback the row invokes itself sidesteps that path entirely.
class QuizQuestionOverviewScreen extends StatelessWidget {
  const QuizQuestionOverviewScreen({
    super.key,
    required this.quiz,
    required this.answers,
    required this.onSelectQuestion,
  });

  final QuizResponse quiz;
  final Map<int, QuizAnswer> answers;
  final ValueChanged<int> onSelectQuestion;

  bool _isAnswered(int index) {
    final question = quiz.questions[index];
    final answer = answers[index];

    if (answer == null) return false;

    return switch (question.type) {
      QuestionType.openEnded => answer.openEndedAnswer.trim().isNotEmpty,
      _ => answer.selectedOptionIndex != null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Overview'),
        actions: [
          HelpMenuButton(
            pageId: 'quiz-question-overview',
            topics: quizQuestionOverviewHelpTopics(),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: quiz.questions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final answer = answers[index];
          final answered = _isAnswered(index);
          final notImportant = answer?.notImportant == true;

          final (icon, color) = notImportant
              ? (Icons.flag_outlined, palette.textMuted)
              : answered
                  ? (Icons.check_circle_outline, palette.success)
                  : (Icons.radio_button_unchecked, palette.textMuted);

          final row = Material(
            color: palette.panelStrong.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelectQuestion(index),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${index + 1}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            quiz.questions[index].question,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: palette.textMuted),
                          ),
                        ],
                      ),
                    ),
                    if (answer?.notImportant == true) ...[
                      const SizedBox(width: 8),
                      _StatusBadge(
                        label: 'Not Important',
                        color: palette.textMuted,
                      ),
                    ],
                    if (answer?.guessed == true) ...[
                      const SizedBox(width: 8),
                      _StatusBadge(
                        label: 'Guess',
                        color: palette.warning,
                      ),
                    ],
                    if (answer?.markedForReview == true) ...[
                      const SizedBox(width: 8),
                      _StatusBadge(
                        label: 'Review',
                        color: palette.brandEnd,
                      ),
                    ],
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, color: palette.textMuted),
                  ],
                ),
              ),
            ),
          );

          // Anchored only on the first row -- ListView.separated lazily
          // builds items near the viewport, but the first is always among
          // them, so it's a reliable, always-mounted anchor without
          // registering the same anchor id against more than one widget.
          if (index == 0) {
            return HelpAnchor(
              pageId: 'quiz-question-overview',
              anchorId: 'question-row-first',
              child: row,
            );
          }

          return row;
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
