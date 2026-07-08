import 'package:flutter/material.dart';

import '../../data/models/course_model.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.name),
      ),
      body: Center(
        child: Text(
          'Course details coming soon.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}