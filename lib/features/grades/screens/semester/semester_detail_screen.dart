import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/semester_model.dart';
import '../../widgets/common/grade_speed_dial.dart';
import '../../widgets/course/course_actions.dart';
import '../../widgets/semester/semester_detail_body.dart';
import '../../widgets/semester/semester_detail_popup_menu.dart';
import '../../widgets/dialogs/course/create_course_dialog.dart';
import '../grading/create_grading_structure_screen.dart';
import '../../data/models/course_model.dart';

class SemesterDetailScreen extends ConsumerWidget {
  const SemesterDetailScreen({
    super.key,
    required this.semester,
  });

  final SemesterModel semester;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    return Scaffold(
        appBar: AppBar(
          title: Text(semester.name),
          actions: [
            SemesterDetailPopupMenu(
              semester: semester,
            ),
          ],
        ),
      body: SemesterDetailBody(
        semester: semester,
      ),
      floatingActionButton: GradeSpeedDial(
        onCreateCourse: () async {
          final createdCourse =
          await showDialog<CourseModel>(
            context: context,
            builder: (_) =>
                CreateCourseDialog(
                  semesterId: semester.id,
                ),
          );

          if (!context.mounted ||
              createdCourse == null) {
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateGradingStructureScreen(
                    course: createdCourse,
                    isEditing: false,
                  ),
            ),
          );
        },
        onImportCourse: () {
          CourseActions.import(
            context,
            ref,
            semester.id,
          );
        },
      ),
    );
  }
}