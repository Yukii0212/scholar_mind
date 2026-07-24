import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DashboardDayEventsSheet extends StatelessWidget {
  const DashboardDayEventsSheet({
    super.key,
    required this.date,
    required this.onAddCountdown,
  });

  final DateTime date;
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