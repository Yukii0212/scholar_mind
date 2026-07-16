import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/semester_model.dart';
import '../../../providers/semester/semester_provider.dart';

class DeleteSemesterDialog extends ConsumerWidget {
  const DeleteSemesterDialog({
    super.key,
    required this.semester,
  });

  final SemesterModel semester;

  Future<void> _deleteSemester(BuildContext context, WidgetRef ref) async {
    await ref
        .read(semesterRepositoryProvider)
        .deleteSemester(semester.id);

    if (!context.mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Delete Semester',
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

              Text(
                'Are you sure you want to delete',
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 8),

              Text(
                '"${semester.name}"',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 16),

              const Text(
                'This action cannot be undone.',
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _deleteSemester(context, ref),
                  icon: const Icon(Icons.delete),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                    Theme.of(context).colorScheme.error,
                    foregroundColor:
                    Theme.of(context).colorScheme.onError,
                  ),
                  label: const Text('Delete'),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
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