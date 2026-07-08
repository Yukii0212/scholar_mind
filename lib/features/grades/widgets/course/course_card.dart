import 'package:flutter/material.dart';

import '../../data/models/course_model.dart';
import 'course_popup_menu.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.onOpen,
  });

  final CourseModel course;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onOpen,
        title: Text(course.name),
        subtitle: course.targetGrade == null
            ? const Text('No target grade')
            : Text(
          'Target Grade: ${course.targetGrade}',
        ),
        trailing: CoursePopupMenu(
          course: course,
        ),
      ),
    );
  }
}