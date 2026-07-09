import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_mind/features/grades/widgets/dialogs/course/import_course_dialog.dart';

import '../../data/models/course_model.dart';
import '../../providers/course/course_provider.dart';
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

  static Future<void> import(
      BuildContext context,
      WidgetRef ref,
      String? semesterId,
      ) async {
    final selected =
    await showDialog<CourseModel>(
      context: context,
      builder: (_) => const ImportCourseDialog(),
    );

    if (selected == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => EditCourseDialog(
        course: selected.copyWith(
          semesterId: semesterId,
        ),
        isImport: true,
        title: 'Review Imported Course',
      ),
    );
  }
}