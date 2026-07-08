import 'package:flutter/material.dart';

import '../../data/models/course_model.dart';
import 'course_actions.dart';
import 'course_card.dart';

class CourseList extends StatelessWidget {
  const CourseList({
    super.key,
    required this.courses,
  });

  final List<CourseModel> courses;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return const Center(
        child: Text(
          'No courses yet.\nTap + to create your first course.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];

        return CourseCard(
          course: course,
          onOpen: () => CourseActions.open(
            context,
            course,
          ),
        );
      },
    );
  }
}