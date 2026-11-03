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
    this.errorText,
  });

  final String label;
  final String? errorText;
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

    final fields = <Widget>[
      if (showDay)
        DropdownButtonFormField<int>(
          initialValue: day,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Day',
            errorText: errorText != null ? '' : null,
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
      DropdownButtonFormField<int>(
        initialValue: month,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Month',
          errorText: errorText != null ? '' : null,
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
      DropdownButtonFormField<int>(
        initialValue: year,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Year',
          errorText: errorText != null ? '' : null,
        ),
        items: List.generate(
          21,
          (index) {
            final selectableYear = currentYear - 10 + index;
            return DropdownMenuItem(
              value: selectableYear,
              child: Text('$selectableYear'),
            );
          },
        ),
        onChanged: (value) {
          if (value != null) {
            onYearChanged(value);
          }
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 16.0;
                const minimumFieldWidth = 112.0;
                final maximumColumns = fields.length;
                final availableColumns = showDay && constraints.maxWidth < 420
                    ? 1
                    : ((constraints.maxWidth + spacing) /
                            (minimumFieldWidth + spacing))
                        .floor()
                        .clamp(1, maximumColumns);
                final fieldWidth = (constraints.maxWidth -
                        (spacing * (availableColumns - 1))) /
                    availableColumns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final field in fields)
                      SizedBox(
                        width: fieldWidth,
                        child: field,
                      ),
                  ],
                );
              },
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: 4,
                  left: 12,
                ),
                child: Text(
                  errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
