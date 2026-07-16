import 'package:flutter/material.dart';

import '../../data/models/course_model.dart';

class CourseInformationCard extends StatelessWidget {
  const CourseInformationCard({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(course.name),
        subtitle: Text(
          course.targetScore == null
              ? 'No target score'
              : 'Target Score: ${course.targetScore}',
        ),
      ),
    );
  }
}