import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/semester_model.dart';

class SemesterCard extends StatelessWidget {
  const SemesterCard({
    super.key,
    required this.semester,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleHidden,
  });

  final SemesterModel semester;

  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onToggleHidden;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(
          semester.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${DateFormat('MMM yyyy').format(semester.startDate)} - '
              '${DateFormat('MMM yyyy').format(semester.endDate)}',
        ),
        children: [
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Open'),
            onTap: onOpen,
          ),
          ListTile(
            leading: const Icon(Icons.edit_calendar_outlined),
            title: const Text('Edit Semester'),
            onTap: onEdit,
          ),
          if (!semester.isCurrent)
            ListTile(
              leading: Icon(
                semester.isHidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              title: Text(
                semester.isHidden
                    ? 'Unhide'
                    : 'Hide',
              ),
              onTap: onToggleHidden,
            ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}