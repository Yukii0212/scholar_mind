import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import '../../providers/grading/grading_structure_controller.dart';
import '../../screens/grading/create_grading_structure_screen.dart';
import '../../providers/grading/grading_provider.dart';
import '../grading/component/grading_component_summary_list.dart';

class CourseDetailBody extends ConsumerStatefulWidget {
  const CourseDetailBody({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  ConsumerState<CourseDetailBody> createState() => CourseDetailBodyState();
}

class CourseDetailBodyState extends ConsumerState<CourseDetailBody> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    await ref.read(gradingStructureControllerProvider).loadCourse(
          widget.course.id,
        );

    if (!mounted) return;

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Consumer(
        builder: (context, ref, _) {
          final repository = ref.watch(gradingComponentRepositoryProvider);

          return StreamBuilder(
            stream: repository.watchCourseComponents(widget.course.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final components = snapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Assessment',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (components.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CreateGradingStructureScreen(
                                    course: widget.course,
                                    isEditing: true,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Assessment'),
                          ),
                      ],
                    ),
                    if (components.isEmpty) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateGradingStructureScreen(
                                course: widget.course,
                                isEditing: false,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create Assessment'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    GradingComponentSummaryList(components: components),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
