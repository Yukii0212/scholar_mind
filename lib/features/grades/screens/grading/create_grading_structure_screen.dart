import 'package:flutter/material.dart';

import '../../data/models/course_model.dart';
import '../../widgets/course/course_information_card.dart';
import '../../widgets/grading/grading_structure_actions.dart';
import '../../widgets/grading/grading_structure_card.dart';
import '../../widgets/grading/grading_structure_editor.dart';

class CreateGradingStructureScreen
    extends StatelessWidget {
  const CreateGradingStructureScreen({
    super.key,
    required this.course,
    this.isEditing = false,
  });

  final CourseModel course;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Grading Structure'
              : 'Create Grading Structure',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              CourseInformationCard(
                course: course,
              ),

              const SizedBox(height: 16),

              GradingStructureEditor(
                courseId: course.id,
                isEditing: isEditing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}