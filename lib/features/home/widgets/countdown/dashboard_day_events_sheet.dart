import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../countdown/domain/countdown_item.dart';

class DashboardDayEventsSheet extends StatelessWidget {
  const DashboardDayEventsSheet({
    super.key,
    required this.date,
    required this.countdowns,
    required this.onAddCountdown,
  });

  final DateTime date;
  final List<CountdownItem> countdowns;
  final VoidCallback onAddCountdown;

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
                    ),
                    if (i != countdowns.length - 1)
                      const Divider(height: 20),
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
  });

  final CountdownItem item;

  @override
  Widget build(BuildContext context) {
    final days = item.daysRemaining;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        _iconFor(item.type),
      ),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${item.type.label} • Priority ${item.priority}',
      ),
      trailing: Text(
        switch (days) {
          < 0 => 'Overdue',
          0 => 'Today',
          1 => '1 day',
          _ => '$days days',
        },
        style: Theme.of(context).textTheme.labelMedium,
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