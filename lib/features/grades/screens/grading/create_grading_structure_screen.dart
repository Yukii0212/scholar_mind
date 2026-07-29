import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../help/widgets/help_menu_button.dart';
import '../../data/models/course_model.dart';
import '../../help/grading_structure_help_topics.dart';
import '../../help/grading_structure_preview_provider.dart';
import '../../widgets/course/course_information_card.dart';
import '../../widgets/grading/structures/grading_structure_editor.dart';

class CreateGradingStructureScreen extends ConsumerWidget {
  const CreateGradingStructureScreen({
    super.key,
    required this.course,
    this.isEditing = false,
  });

  final CourseModel course;
  final bool isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Grading Structure'
              : 'Create Grading Structure',
        ),
        actions: [
          HelpMenuButton(
            pageId: 'grading-structure',
            topics: gradingStructureHelpTopics(
              setPreviewMode: (value) => ref
                  .read(gradingStructureHelpPreviewProvider.notifier)
                  .state = value,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CourseInformationCard(course: course),
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
