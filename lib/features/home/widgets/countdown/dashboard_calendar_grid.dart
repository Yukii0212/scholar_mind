import 'package:flutter/material.dart';

import 'dashboard_calendar_day.dart';

class DashboardCalendarGrid extends StatelessWidget {
  const DashboardCalendarGrid({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.onDateSelected,
    required this.eventCountBuilder,
  });

  final List<DateTime?> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final int Function(DateTime date) eventCountBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: .68,
      ),
      itemBuilder: (context, index) {
        final day = days[index];

        return DashboardCalendarDay(
          date: day,
          isToday: day != null && _isSameDate(day, DateTime.now()),
          isSelected:
          day != null && _isSameDate(day, selectedDate),
          eventCount:
          day == null ? 0 : eventCountBuilder(day),
          onTap: day == null
              ? null
              : () => onDateSelected(day),
        );
      },
    );
  }

  bool _isSameDate(
      DateTime a,
      DateTime b,
      ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}