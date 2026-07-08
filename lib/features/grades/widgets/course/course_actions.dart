import 'package:flutter/material.dart';
import 'package:scholar_mind/features/grades/widgets/dialogs/course/import_course_dialog.dart';

import '../../data/models/course_model.dart';
import '../../screens/course/course_detail_screen.dart';
import '../../widgets/dialogs/course/delete_course_dialog.dart';
import '../../widgets/dialogs/course/edit_course_dialog.dart';

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
    showDialog(
      context: context,
      builder: (_) => EditCourseDialog(
        course: course,
      ),
    );
  }

  static void delete(
      BuildContext context,
      CourseModel course,
      ) {
    showDialog(
      context: context,
      builder: (_) => DeleteCourseDialog(
        course: course,
      ),
    );
  }

  static void import(
      BuildContext context,
      CourseModel course,
      ) {
    showDialog(
      context: context,
      builder: (_) => ImportCourseDialog(
    ),
    );
  }
}