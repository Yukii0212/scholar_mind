import 'package:flutter/material.dart';

import '../../data/models/course_model.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.expanded,
    required this.onExpansionChanged,
  });

  final CourseModel course;

  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final bool expanded;

  final ValueChanged<bool>
  onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        key: PageStorageKey(
          course.id,
        ),
        initiallyExpanded:
        expanded,
        onExpansionChanged:
        onExpansionChanged,
        title: Text(
          course.name,
          style: Theme.of(context)
              .textTheme
              .titleMedium,
        ),
        subtitle: Text(
          course.targetScore == null
              ? 'No target score'
              : 'Target Score: '
              '${course.targetScore!.toStringAsFixed(0)}%',
        ),
        children: [
          ListTile(
            leading: const Icon(
              Icons.open_in_new,
            ),
            title: const Text(
              'Open',
            ),
            onTap: onOpen,
          ),
          ListTile(
            leading: const Icon(
              Icons.edit_outlined,
            ),
            title: const Text(
              'Edit Course',
            ),
            onTap: onEdit,
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context)
                  .colorScheme
                  .error,
            ),
            title: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .error,
              ),
            ),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}