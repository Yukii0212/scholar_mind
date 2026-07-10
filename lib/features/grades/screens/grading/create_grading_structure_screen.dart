import 'package:flutter/material.dart';

import '../../data/models/course_model.dart';
import '../../widgets/grading/grading_structure_actions.dart';
import '../../widgets/grading/grading_structure_card.dart';

class CreateGradingStructureScreen
    extends StatelessWidget {
  const CreateGradingStructureScreen({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Grading Structure',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              const GradingStructureCard(),

              const SizedBox(height: 24),

              GradingStructureActions(
                courseId: course.id,
              ),
            ],
          ),
        ),
      ),
    );
  }
}