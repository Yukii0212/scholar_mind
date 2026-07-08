import 'package:flutter/material.dart';

import '../../data/models/course_model.dart';
import 'course_actions.dart';

class CoursePopupMenu extends StatelessWidget {
  const CoursePopupMenu({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            CourseActions.edit(
              context,
              course,
            );
            break;

          case 'delete':
            CourseActions.delete(
              context,
              course,
            );
            break;
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit Course'),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete Course'),
        ),
      ],
    );
  }
}