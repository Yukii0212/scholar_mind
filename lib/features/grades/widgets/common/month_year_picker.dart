import 'package:flutter/material.dart';

class MonthYearPicker extends StatelessWidget {
  const MonthYearPicker({
    super.key,
    required this.label,
    required this.month,
    required this.year,
    required this.onMonthChanged,
    required this.onYearChanged,
    this.showDay = false,
    this.day,
    this.onDayChanged,
  });

  final String label;
  final int month;
  final int year;
  final bool showDay;
  final int? day;

  final ValueChanged<int>? onDayChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  static const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [

            if (showDay) ...[
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: day,
                  decoration: const InputDecoration(
                    labelText: 'Day',
                  ),
                  items: List.generate(
                    31,
                        (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      onDayChanged?.call(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
            ],

            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: month,
                decoration: const InputDecoration(
                  labelText: 'Month',
                ),
                items: List.generate(
                  12,
                      (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(months[index]),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    onMonthChanged(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: year,
                decoration: const InputDecoration(
                  labelText: 'Year',
                ),
                items: List.generate(
                  21,
                      (index) {
                    final y = currentYear - 10 + index;
                    return DropdownMenuItem(
                      value: y,
                      child: Text('$y'),
                    );
                  },
                ),
                onChanged: (value) {
                  if (value != null) {
                    onYearChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}