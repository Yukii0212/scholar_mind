import 'package:flutter/material.dart';

import '../../data/models/course_model.dart';
import '../../widgets/grading/grading_structure_editor.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                title: Text(course.name),
                subtitle: Text(
                  course.targetGrade == null
                      ? 'No target grade'
                      : 'Target Grade: ${course.targetGrade}',
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Grading Structure',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),

            const SizedBox(height: 12),

            const Expanded(
              child: GradingStructureEditor(),
            ),
          ],
        ),
      ),
    );
  }
}