import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import '../../providers/course/course_provider.dart';
import '../../providers/grading/grading_structure_controller.dart';
import '../../screens/grading/create_grading_structure_screen.dart';
import '../../providers/grading/grading_provider.dart';
import '../grading/component/grading_component_summary_list.dart';
import 'course_standing_card.dart';

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
          Expanded(
            child: Consumer(
              builder:
                  (
                  context,
                  ref,
                  _,
                  ) {

                final repository =
                ref.watch(
                  gradingComponentRepositoryProvider,
                );

                return StreamBuilder(
                  stream:
                  repository
                      .watchCourseComponents(
                    widget.course.id,
                  ),
                  builder:
                      (
                      context,
                      snapshot,
                      ) {

                    if (!snapshot.hasData) {
                      return const Center(
                        child:
                        CircularProgressIndicator(),
                      );
                    }

                    final data =
                    snapshot.data!;

                    return SingleChildScrollView(
                      padding:
                      const EdgeInsets.only(
                        bottom: 24,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                        children: [

                          Consumer(
                            builder: (
                                context,
                                ref,
                                _,
                                ) {
                              final course =
                              ref.watch(
                                courseProvider(
                                  widget.course.id,
                                ),
                              );

                              return course.when(
                                loading: () =>
                                const Card(
                                  child: Padding(
                                    padding:
                                    EdgeInsets.all(24),
                                    child:
                                    CircularProgressIndicator(),
                                  ),
                                ),

                                error: (_, __) =>
                                const SizedBox(),

                                data: (course) =>
                                    CurrentStandingCard(
                                      course: course,
                                      courseId: course.id,
                                      components: data,
                                    ),
                              );
                            },
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Grading Structure',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge,
                                ),
                              ),

                              if (data.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CreateGradingStructureScreen(
                                              course: widget.course,
                                              isEditing: true,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                  ),
                                  label: const Text(
                                    'Edit Structure',
                                  ),
                                ),
                            ],
                          ),

                          if (data.isEmpty) ...[
                            const SizedBox(height: 16),

                            FilledButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CreateGradingStructureScreen(
                                          course: widget.course,
                                          isEditing: false,
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.add,
                              ),
                              label: const Text(
                                'Create Structure',
                              ),
                            ),
                          ],

                          const SizedBox(
                            height: 16,
                          ),

                          GradingComponentSummaryList(
                            components: data,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGradingStructure
    extends StatelessWidget {
  const _EmptyGradingStructure();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(height: 24),

            Text(
              'No grading structure yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'Create a grading structure or use one of your saved templates to begin tracking this course.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}