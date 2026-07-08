import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/course_model.dart';
import '../../../providers/course/course_provider.dart';

class DeleteCourseDialog extends ConsumerStatefulWidget {
  const DeleteCourseDialog({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  ConsumerState<DeleteCourseDialog> createState() =>
      _DeleteCourseDialogState();
}

class _DeleteCourseDialogState
    extends ConsumerState<DeleteCourseDialog> {
  bool _isDeleting = false;

  Future<void> _delete() async {
    setState(() {
      _isDeleting = true;
    });

    await ref
        .read(courseRepositoryProvider)
        .deleteCourse(widget.course.id);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Delete Course?',
      ),
      content: Text(
        'Are you sure you want to delete "${widget.course.name}"?\n\nThis action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
          _isDeleting ? null : _delete,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}