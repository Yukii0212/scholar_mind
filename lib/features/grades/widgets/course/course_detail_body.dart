import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import '../../providers/grading/grading_structure_controller.dart';
import '../grading/grading_structure_editor.dart';
import 'course_information_card.dart';

class CourseDetailBody extends ConsumerStatefulWidget {
  const CourseDetailBody({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  ConsumerState<CourseDetailBody> createState() =>
      CourseDetailBodyState();
}

class CourseDetailBodyState
    extends ConsumerState<CourseDetailBody> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    await ref
        .read(
      gradingStructureControllerProvider,
    )
        .loadCourse(widget.course.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> save() async {
    await ref
        .read(
      gradingStructureControllerProvider,
    )
        .saveCourse(widget.course.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Grading structure saved.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          CourseInformationCard(
            course: widget.course,
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
    );
  }
}