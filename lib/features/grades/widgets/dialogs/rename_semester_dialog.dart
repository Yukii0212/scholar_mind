import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/semester_model.dart';
import '../../providers/semester/semester_provider.dart';

class RenameSemesterDialog extends ConsumerStatefulWidget {
  const RenameSemesterDialog({
    super.key,
    required this.semester,
  });

  final SemesterModel semester;

  @override
  ConsumerState<RenameSemesterDialog> createState() =>
      _RenameSemesterDialogState();
}

class _RenameSemesterDialogState
    extends ConsumerState<RenameSemesterDialog> {
  late final TextEditingController _controller;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.semester.name,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _renameSemester() async {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Semester name is required.';
      });
      return;
    }

    await ref
        .read(semesterRepositoryProvider)
        .renameSemester(
      semesterId: widget.semester.id,
      name: name,
    );

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rename Semester',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _controller,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  border:
                  const OutlineInputBorder(),
                  labelText: 'Semester Name',
                  errorText: _errorMessage,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _renameSemester,
                  child: const Text('Save'),
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
    );
  }
}