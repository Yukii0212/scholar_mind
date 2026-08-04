import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../domain/countdown_item.dart';

class CountdownCard extends StatefulWidget {
  const CountdownCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onHide,
  });

  final CountdownItem item;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onHide;

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final item = widget.item;

    final days = item.daysRemaining;
    final overdue = !item.isEffectivelyCompleted && days < 0;

    return ScholarPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ScholarIconBadge(
                      icon: switch (item.type) {
                        CountdownType.assignment =>
                        Icons.assignment_outlined,
                        CountdownType.quiz =>
                        Icons.quiz_outlined,
                        CountdownType.lab =>
                        Icons.science_outlined,
                        CountdownType.presentation =>
                        Icons.slideshow_outlined,
                        CountdownType.project =>
                        Icons.work_outline,
                        CountdownType.midterm =>
                        Icons.school_outlined,
                        CountdownType.finalExamination =>
                        Icons.event_note_outlined,
                        CountdownType.personal =>
                        Icons.person_outline,
                        CountdownType.other =>
                        Icons.event_outlined,
                      },
                      size: 54,
                      color: palette.brandStart,
                    ),

                    const Gap(16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w900,
                              decoration: item.isEffectivelyCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),

                          const Gap(6),

                          Text(
                            '${item.type.label} • ${item.priority.priorityLabel}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              color: palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.isEffectivelyCompleted
                              ? 'Completed'
                              : _daysText(days),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            color: overdue
                                ? palette.warning
                                : palette.brandEnd,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const Gap(8),

                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.expand_more_rounded,
                            color: palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: !_expanded
                  ? const SizedBox.shrink()
                  : Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin:
                      const EdgeInsets.only(bottom: 16),
                      height: 1,
                      color: palette.stroke,
                    ),

                    if ((item.description ?? '')
                        .trim()
                        .isNotEmpty) ...[
                      Text(
                        item.description!.trim(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                      const Gap(16),
                    ],

                    if (item.deadlineExtendable)
                      Padding(
                        padding:
                        const EdgeInsets.only(bottom: 16),
                        child: _CountdownPill(
                          text: overdue
                              ? 'Extendable overdue'
                              : 'Extendable',
                          color: overdue
                              ? palette.warning
                              : palette.success,
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: Icon(
                          item.isCompleted
                              ? Icons.undo
                              : Icons.check,
                        ),
                        label: Text(
                          item.isCompleted
                              ? 'Mark as Active'
                              : 'Mark as Completed',
                        ),
                        onPressed: widget.onToggle == null
                            ? null
                            : () => widget.onToggle!(
                          !item.isCompleted,
                        ),
                      ),
                    ),

                    const Gap(10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                        label: const Text('Edit'),
                        onPressed: widget.onEdit,
                      ),
                    ),

                    const Gap(10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(
                          item.isHidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        label: Text(
                          item.isHidden ? 'Unhide' : 'Hide',
                        ),
                        onPressed: widget.onHide,
                      ),
                    ),

                    const Gap(10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.delete_outline,
                        ),
                        label: const Text('Delete'),
                        onPressed: widget.onDelete,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownPill extends StatelessWidget {
  const _CountdownPill({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _daysText(int days) {
  if (days < 0) return '${days.abs()} days late';
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  return '$days days';
}