import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_mind/features/grades/widgets/dialogs/course/import_course_dialog.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/providers/auth_provider.dart';
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
    String semesterId,
  ) async {
    final selected = await showDialog<CourseModel>(
      context: context,
      builder: (_) => const ImportCourseDialog(),
    );

    if (selected == null || !context.mounted) {
      return;
    }

    final userId = ref.read(activeUserProvider)?.uid;

    if (userId == null) {
      return;
    }

    final now = DateTime.now();
    final reviewedCourse = await showDialog<CourseModel>(
      context: context,
      builder: (_) => EditCourseDialog(
        course: selected.copyWith(
          id: '',
          ownerId: userId,
          semesterId: semesterId,
          createdAt: now,
          updatedAt: now,
        ),
        isImport: true,
        title: 'Review Copied Course',
      ),
    );

    if (reviewedCourse == null ||
        !context.mounted ||
        ref.read(activeUserProvider)?.uid != userId) {
      return;
    }

    final components = await ref
        .read(
          gradingComponentRepositoryProvider,
        )
        .getCourseComponents(
          userId,
          selected.id,
        );

    if (ref.read(activeUserProvider)?.uid != userId) {
      return;
    }

    final copiedCourse = await ref
        .read(
          courseRepositoryProvider,
        )
        .copyCourse(
          userId: userId,
          source: reviewedCourse,
          semesterId: semesterId,
        );

    final idMap = <String, String>{};

    for (final component in components) {
      idMap[component.id] = const Uuid().v4();
    }

    final copiedComponents = components.map(
      (component) {
        final newId = idMap[component.id]!;

        final newParentId =
            component.parentId == null ? null : idMap[component.parentId!];

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
          userId: userId,
          courseId: copiedCourse.id,
          components: copiedComponents,
        );

    if (!context.mounted ||
        ref.read(activeUserProvider)?.uid != userId) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
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
