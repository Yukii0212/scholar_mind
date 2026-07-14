import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_mind/features/grades/widgets/dialogs/course/import_course_dialog.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/course_model.dart';
import '../../providers/course/course_provider.dart';
import '../../providers/grading/grading_provider.dart';
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

  static Future<void> copyFromExistingCourse(
      BuildContext context,
      WidgetRef ref,
      String? semesterId,
      ) async {

    final selected =
    await showDialog<CourseModel>(
      context: context,
      builder: (_) =>
      const ImportCourseDialog(),
    );

    if (selected == null ||
        !context.mounted) {
      return;
    }

    final copiedCourse =
    await ref
        .read(
      courseRepositoryProvider,
    )
        .copyCourse(
      source: selected,
      semesterId: semesterId,
    );

    final components =
    await ref
        .read(
      gradingComponentRepositoryProvider,
    )
        .getCourseComponents(
      selected.id,
    );

    final idMap = <String, String>{};

    for (final component in components) {
      idMap[component.id] =
          const Uuid().v4();
    }

    final copiedComponents =
    components.map(
          (component) {

        final newId =
        idMap[component.id]!;

        final newParentId =
        component.parentId == null
            ? null
            : idMap[
        component.parentId!
        ];

        return component.copyWith(
          id: newId,
          courseId: copiedCourse.id,
          parentId: newParentId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      },
    ).toList();

    await ref
        .read(
      gradingComponentRepositoryProvider,
    )
        .replaceCourseComponents(
      courseId:
      copiedCourse.id,
      components:
      copiedComponents,
    );

    if (!context.mounted) {
      return;
    }

    await showDialog(
      context: context,
      builder: (_) =>
          EditCourseDialog(
            course: copiedCourse,
            isImport: true,
            title:
            'Review Copied Course',
          ),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '${copiedCourse.name} copied successfully.',
        ),
        action: SnackBarAction(
          label: 'OPEN',
          onPressed: () {
            CourseActions.open(
              context,
              copiedCourse,
            );
          },
        ),
      ),
    );
  }
}