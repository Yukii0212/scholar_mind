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
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Semester',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Semester 2 2026',
                    helperText: 'Enter a name for this semester',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                ),

                const SizedBox(height: 24),

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

                const SizedBox(height: 24),

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
            ),
          ),
        ),
      ),
    );
  }
}