import 'package:flutter/material.dart';

import '../../data/models/course_model.dart';
import 'course_actions.dart';
import 'course_card.dart';

class CourseList
    extends StatefulWidget {
  const CourseList({
    super.key,
    required this.courses,
  });

  final List<CourseModel>
  courses;

  @override
  State<CourseList> createState() =>
      _CourseListState();
}

class _CourseListState
    extends State<CourseList> {

  String? expandedCourseId;

  @override
  Widget build(
      BuildContext context,
      ) {
    if (widget.courses.isEmpty) {
      return const Center(
        child: Text(
          'No courses yet.\nTap + to create your first course.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      itemCount:
      widget.courses.length,
      itemBuilder: (
          context,
          index,
          ) {
        final course =
        widget.courses[index];

        return CourseCard(
          course: course,
          expanded:
          expandedCourseId ==
              course.id,
          onExpansionChanged:
              (expanded) {
            setState(() {
              if (expanded) {
                expandedCourseId =
                    course.id;
              } else if (expandedCourseId ==
                  course.id) {
                expandedCourseId =
                null;
              }
            });
          },
          onOpen: () =>
              CourseActions.open(
                context,
                course,
              ),
          onEdit: () =>
              CourseActions.edit(
                context,
                course,
              ),
          onDelete: () =>
              CourseActions.delete(
                context,
                course,
              ),
        );
      },
    );
  }
}