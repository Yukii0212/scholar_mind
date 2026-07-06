import 'package:flutter/material.dart';
import 'month_year_picker.dart';

class CreateSemesterDialog extends StatefulWidget {
  const CreateSemesterDialog({super.key});

  @override
  State<CreateSemesterDialog> createState() =>
      _CreateSemesterDialogState();
}

class _CreateSemesterDialogState
    extends State<CreateSemesterDialog> {
  final _nameController = TextEditingController();

  final now = DateTime.now();

  late int _startDay = now.day;
  late int _startMonth = now.month;
  late int _startYear = now.year;

  late int _endDay = now.day;
  late int _endMonth = now.month;
  late int _endYear = now.year;

  bool _useExactDates = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Semester'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Semester Name',
                hintText: 'Semester 2 2026',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school_outlined),
              ),
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Duration',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            const SizedBox(height: 16),

            MonthYearPicker(
              label: 'Start',
              showDay: _useExactDates,
              day: _startDay,
              month: _startMonth,
              year: _startYear,
              onDayChanged: (value) {
                setState(() => _startDay = value);
              },
              onMonthChanged: (value) {
                setState(() => _startMonth = value);
              },
              onYearChanged: (value) {
                setState(() => _startYear = value);
              },
            ),

            const SizedBox(height: 24),

            MonthYearPicker(
              label: 'End',
              showDay: _useExactDates,
              day: _endDay,
              month: _endMonth,
              year: _endYear,
              onDayChanged: (value) {
                setState(() => _endDay = value);
              },
              onMonthChanged: (value) {
                setState(() => _endMonth = value);
              },
              onYearChanged: (value) {
                setState(() => _endYear = value);
              },
            ),

            const SizedBox(height: 24),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Specify exact dates'),
              value: _useExactDates,
              onChanged: (value) {
                setState(() {
                  _useExactDates = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ),
      ],

    );
  }
}