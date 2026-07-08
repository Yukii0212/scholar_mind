import 'package:flutter/material.dart';

import '../../data/models/course_model.dart';
import '../../screens/course/course_detail_screen.dart';

class CourseActions {
  const CourseActions._();

  static void open(
      BuildContext context,
      CourseModel course,
      ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(
          course: course,
        ),
      ),
    );
  }

  static void edit(
      BuildContext context,
      CourseModel course,
      ) {
    // TODO: Edit Course
  }

  static void delete(
      BuildContext context,
      CourseModel course,
      ) {
    // TODO: Delete Course
  }

  static void import(
      BuildContext context,
      ) {
    // TODO: Import Course
  }
}