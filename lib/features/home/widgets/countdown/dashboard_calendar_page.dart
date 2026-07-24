import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_design.dart';
import 'dashboard_calendar_day.dart';
import 'dashboard_calendar_grid.dart';
import 'dashboard_day_events_sheet.dart';

class DashboardCalendarPage extends StatefulWidget {
  const DashboardCalendarPage({
    super.key,
  });

  @override
  State<DashboardCalendarPage> createState() =>
      _DashboardCalendarPageState();
}

class _DashboardCalendarPageState
    extends State<DashboardCalendarPage> {
  DateTime _displayedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  /// 1 = Monday ... 7 = Sunday.
  /// This will later come from user preferences.
  int _firstDayOfWeek = DateTime.monday;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    final days = _buildCalendarDays(
      month: _displayedMonth,
      firstDayOfWeek: _firstDayOfWeek,
    );

    return ScholarPanel(
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
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month + 1,
                    );
                  });
                },
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
              // TODO:
              // Replace with countdown provider.
              return switch (date.day % 5) {
                0 => 2,
                1 => 1,
                _ => 0,
              };
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
    );
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
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return DashboardDayEventsSheet(
          date: date,
          onAddCountdown: () {
            Navigator.pop(context);

            // TODO:
            // Navigate to Countdown CRUD
            // with the selected date.
          },
        );
      },
    );
  }
}