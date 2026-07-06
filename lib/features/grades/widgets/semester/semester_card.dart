import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/semester_model.dart';

class SemesterCard extends StatelessWidget {
  const SemesterCard({
    super.key,
    required this.semester,
    required this.onOpen,
    required this.onRename,
    required this.onEdit,
    required this.onDelete,
  });

  final SemesterModel semester;

  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
            title: const Text('Edit Duration'),
            onTap: onEdit,
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: const Text('Rename'),
            onTap: onRename,
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