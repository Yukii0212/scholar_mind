import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import '../../domain/assessment/assessment_type.dart';
import '../../providers/assessment/assessment_provider.dart';
import '../../providers/course/course_provider.dart';
import '../../providers/grading/grading_structure_controller.dart';
import '../../screens/grading/create_grading_structure_screen.dart';
import '../../providers/grading/grading_provider.dart';
import '../grading/component/grading_component_summary_list.dart';
import '../../../../core/widgets/swipe_cards/swipe_cards.dart';
import '../../../../core/widgets/swipe_cards/swipe_card_item.dart';
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

  bool _showAnalytics = false;

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

    final components =
    await ref
        .read(
      gradingComponentRepositoryProvider,
    )
        .watchCourseComponents(
      widget.course.id,
    )
        .first;

    final entries =
    await ref.read(
      assessmentEntriesProvider(
        widget.course.id,
      ).future,
    );

    final hasScores = entries.any(
          (entry) =>
      entry.type ==
          AssessmentType.actual ||
          entry.type ==
              AssessmentType.expected,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _showAnalytics =
          components.isNotEmpty &&
              hasScores;

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    return Padding(
      padding:
      const EdgeInsets.all(16),
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
            stream: repository
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

              final components =
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

                    SegmentedButton<bool>(
                      segments: const [

                        ButtonSegment(
                          value: true,
                          icon: Icon(
                            Icons.analytics_outlined,
                          ),
                          label: Text(
                            'Analytics',
                          ),
                        ),

                        ButtonSegment(
                          value: false,
                          icon: Icon(
                            Icons.assignment_outlined,
                          ),
                          label: Text(
                            'Assessment',
                          ),
                        ),
                      ],

                      selected: {
                        _showAnalytics,
                      },

                      onSelectionChanged:
                          (selection) {

                        setState(() {
                          _showAnalytics =
                              selection.first;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    if (_showAnalytics)

                      Consumer(
                        builder: (
                            context,
                            ref,
                            _,
                            ) {

                          final liveCourse =
                          ref.watch(
                            courseProvider(
                              widget.course.id,
                            ),
                          );

                          return liveCourse.when(
                            loading: () =>
                            const Card(
                              child: Padding(
                                padding:
                                EdgeInsets.all(
                                  24,
                                ),
                                child:
                                CircularProgressIndicator(),
                              ),
                            ),

                            error: (
                                _,
                                __,
                                ) =>
                            const SizedBox(),

                            data: (course) {

                              return SwipeCards(
                                items: [

                                  SwipeCardItem(
                                    title: 'Overview',
                                    icon: Icons.analytics_outlined,
                                    child:
                                    CurrentStandingCard(
                                      course: course,
                                      courseId:
                                      course.id,
                                      components:
                                      components,
                                    ),
                                  ),

                                  SwipeCardItem(
                                    title: 'Targets',
                                    icon: Icons.flag_outlined,
                                    child: Card(
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.all(
                                          24,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Coming Soon',
                                            style: Theme.of(
                                                context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SwipeCardItem(
                                    title: 'Charts',
                                    icon:
                                    Icons.bar_chart,
                                    child: Card(
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.all(
                                          24,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Coming Soon',
                                            style: Theme.of(
                                                context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )

                    else ...[

                      Row(
                        children: [

                          Expanded(
                            child: Text(
                              'Assessment',
                              style: Theme.of(
                                  context)
                                  .textTheme
                                  .titleLarge,
                            ),
                          ),

                          if (components
                              .isNotEmpty)

                            TextButton.icon(
                              onPressed:
                                  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                        CreateGradingStructureScreen(
                                          course:
                                          widget
                                              .course,
                                          isEditing:
                                          true,
                                        ),
                                  ),
                                );
                              },
                              icon:
                              const Icon(
                                Icons
                                    .edit_outlined,
                              ),
                              label:
                              const Text(
                                'Edit Assessment',
                              ),
                            ),
                        ],
                      ),

                      if (components
                          .isEmpty) ...[

                        const SizedBox(
                          height: 16,
                        ),

                        FilledButton.icon(
                          onPressed:
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                    CreateGradingStructureScreen(
                                      course:
                                      widget
                                          .course,
                                      isEditing:
                                      false,
                                    ),
                              ),
                            );
                          },
                          icon:
                          const Icon(
                            Icons.add,
                          ),
                          label:
                          const Text(
                            'Create Assessment',
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 16,
                      ),

                      GradingComponentSummaryList(
                        components:
                        components,
                      ),
                    ],
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