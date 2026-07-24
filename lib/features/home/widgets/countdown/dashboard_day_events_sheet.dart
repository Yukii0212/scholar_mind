import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_design.dart';
import '../../../countdown/domain/countdown_item.dart';

class DashboardDayEventsSheet extends StatelessWidget {
  const DashboardDayEventsSheet({
    super.key,
    required this.date,
    required this.countdowns,
    required this.onCountdownSelected,
    required this.onAddCountdown,
  });

  final DateTime date;
  final List<CountdownItem> countdowns;
  final VoidCallback onAddCountdown;
  final ValueChanged<CountdownItem> onCountdownSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day} ${_month(date.month)} ${date.year}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Gap(20),

            if (countdowns.isEmpty)
              const Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'No countdowns scheduled.',
                  ),
                  Gap(6),
                  Text(
                    'Tap "Add Countdown" to create one with this date pre-selected.',
                  ),
                ],
              )
            else
              Column(
                children: [
                  for (var i = 0; i < countdowns.length; i++) ...[
                    _CountdownTile(
                      item: countdowns[i],
                      onTap: () => onCountdownSelected(countdowns[i]),
                    ),
                    if (i != countdowns.length - 1)
                      const Gap(10),
                  ],
                ],
              ),

            const Gap(20),
            FilledButton.icon(
              onPressed: onAddCountdown,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add Countdown',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _month(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month];
  }
}

class _CountdownTile extends StatelessWidget {
  const _CountdownTile({
    required this.item,
    required this.onTap,
  });

  final CountdownItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.scholarPalette;
    final days = item.daysRemaining;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: palette.panelStrong.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: palette.stroke.withValues(alpha: 0.7),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ScholarIconBadge(
                  icon: _iconFor(item.type),
                  size: 36,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '${item.type.label} • Priority ${item.priority}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Text(
                  switch (days) {
                    < 0 => 'Overdue',
                    0 => 'Today',
                    1 => '1 day',
                    _ => '$days days',
                  },
                  textAlign: TextAlign.right,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(CountdownType type) {
  return switch (type) {
    CountdownType.assignment => Icons.assignment_outlined,
    CountdownType.quiz => Icons.quiz_outlined,
    CountdownType.lab => Icons.science_outlined,
    CountdownType.presentation => Icons.co_present_outlined,
    CountdownType.project => Icons.account_tree_outlined,
    CountdownType.midterm => Icons.school_outlined,
    CountdownType.finalExamination => Icons.event_note_outlined,
    CountdownType.personal => Icons.bookmark_outline_rounded,
    CountdownType.other => Icons.event_outlined,
  };
}