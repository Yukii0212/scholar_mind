import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/semester_model.dart';
import '../../providers/semester/semester_provider.dart';
import '../../providers/semesters/semester_provider.dart';
import '../common/month_year_picker.dart';

class CreateSemesterDialog extends ConsumerStatefulWidget {
  const CreateSemesterDialog({super.key});

  @override
  ConsumerState<CreateSemesterDialog> createState() =>
      _CreateSemesterDialogState();
}

class _CreateSemesterDialogState
    extends ConsumerState<CreateSemesterDialog> {
  final _nameController = TextEditingController();

  final now = DateTime.now();

  late int _startDay = now.day;
  late int _startMonth = now.month;
  late int _startYear = now.year;

  late int _endDay = now.day;
  late int _endMonth = now.month;
  late int _endYear = now.year;

  bool _useExactDates = false;

  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createSemester() async {
    setState(() {
      _errorMessage = null;
    });

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Semester name is required.';
      });

      return;
    }

    final startDate = DateTime(
      _startYear,
      _startMonth,
      _useExactDates ? _startDay : 1,
    );

    final endDate = _useExactDates
        ? DateTime(
      _endYear,
      _endMonth,
      _endDay,
    )
        : DateTime(
      _endYear,
      _endMonth + 1,
      0,
    );

    final semester = SemesterModel(
      id: '',
      name: name,
      startDate: startDate,
      endDate: endDate,
      isCurrent: false,
      isManuallyEdited: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repository =
    ref.read(semesterRepositoryProvider);

    final hasOverlap =
    await repository.hasOverlappingSemester(
      startDate: startDate,
      endDate: endDate,
    );

    if (hasOverlap) {
      setState(() {
        _errorMessage =
        'Semester dates overlap with an existing semester.';
      });

      return;
    }

    await repository.createSemester(semester);

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Create Semester',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_errorMessage == 'Semester name is required.') {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Semester 2 2026',
                    helperText: 'Enter a name for this semester',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.edit_outlined),
                    errorText: _errorMessage == 'Semester name is required.'
                        ? _errorMessage
                        : null,
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

                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _createSemester,
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