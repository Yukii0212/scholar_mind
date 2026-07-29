import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_design.dart';
import '../../../countdown/domain/countdown_item.dart';
import '../../../countdown/providers/countdown_provider.dart';
import '../../../countdown/screens/countdown_crud_screen.dart';
import 'dashboard_calendar_grid.dart';
import 'dashboard_day_events_sheet.dart';

class DashboardCalendarPage extends ConsumerStatefulWidget {
  const DashboardCalendarPage({
    super.key,
  });

  @override
  ConsumerState<DashboardCalendarPage> createState() =>
      _DashboardCalendarPageState();
}

class _DashboardCalendarPageState
    extends ConsumerState<DashboardCalendarPage> {
  DateTime _displayedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  final int _firstDayOfWeek = DateTime.monday;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    final countdowns =
        ref.watch(countdownsProvider).valueOrNull ??
            const <CountdownItem>[];

    final days = _buildCalendarDays(
      month: _displayedMonth,
      firstDayOfWeek: _firstDayOfWeek,
    );

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;

        if (velocity < -100) {
          _changeMonth(1);
        } else if (velocity > 100) {
          _changeMonth(-1);
        }
      },
      child: ScholarPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _monthYear(_displayedMonth),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const Gap(16),
            Row(
              children: _weekdayHeaders().map((weekday) {
                return Expanded(
                  child: Center(
                    child: Text(
                      weekday,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                        color: palette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Gap(10),
            DashboardCalendarGrid(
              days: days,
              selectedDate: _selectedDate,
              eventCountBuilder: (date) {
                final count = countdowns.where((item) {
                  if (item.isCompleted) return false;

                  return _isSameDate(item.dueDate, date);
                }).length;

                if (count == 0) return 0;
                if (count == 1) return 1;

                return 2;
              },
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });

                _showEventsSheet(
                  context,
                  date,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
      );
    });
  }

  List<DateTime?> _buildCalendarDays({
    required DateTime month,
    required int firstDayOfWeek,
  }) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);

    final offset =
        (first.weekday - firstDayOfWeek + 7) % 7;

    return [
      ...List<DateTime?>.filled(offset, null),
      for (var day = 1; day <= last.day; day++)
        DateTime(month.year, month.month, day),
    ];
  }

  List<String> _weekdayHeaders() {
    const labels = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    final start = _firstDayOfWeek - 1;

    return [
      ...labels.sublist(start),
      ...labels.sublist(0, start),
    ];
  }

  bool _isSameDate(
      DateTime a,
      DateTime b,
      ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _monthYear(DateTime date) {
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

    return '${months[date.month]} ${date.year}';
  }

  void _showEventsSheet(
      BuildContext context,
      DateTime date,
      ) {
    final countdowns =
        ref.read(countdownsProvider).valueOrNull ??
            const <CountdownItem>[];

    final events = countdowns.where((item) {
      return !item.isCompleted &&
          _isSameDate(item.dueDate, date);
    }).toList()
      ..sort((a, b) {
        final priority = b.priority.compareTo(a.priority);
        if (priority != 0) return priority;

        return a.dueDate.compareTo(b.dueDate);
      });

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return DashboardDayEventsSheet(
          date: date,
          countdowns: events,
          onCountdownSelected: (item) {
            Navigator.pop(context);

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CountdownCrudScreen(
                  initial: item,
                ),
              ),
            );
          },
          onAddCountdown: () {
            Navigator.pop(context);

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CountdownCrudScreen(
                  initialDueDate: date,
                ),
              ),
            );
          },
        );
      },
    );
  }
}