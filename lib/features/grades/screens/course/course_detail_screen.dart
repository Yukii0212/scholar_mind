import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import '../../widgets/common/grade_speed_dial.dart';
import '../../widgets/course/course_detail_body.dart';
import '../../widgets/dialogs/grading/create_grading_structure_dialog.dart';
import '../../widgets/grading/grading_structure_editor.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  ConsumerState<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState
    extends ConsumerState<CourseDetailScreen> {
  final GlobalKey<CourseDetailBodyState>
  _bodyKey =
  GlobalKey<CourseDetailBodyState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.name),
        actions: const [],
      ),
      body: CourseDetailBody(
        key: _bodyKey,
        course: widget.course,
      ),

        floatingActionButton: GradeSpeedDial(
          onCreateGradingStructure: () {
            showDialog(
              context: context,
              builder: (_) =>
                  CreateGradingStructureDialog(
                    courseId: widget.course.id,
                  ),
            );
          },
          onImportGradingTemplate: () {
            // TODO
          },
        ),
    );
  }
}