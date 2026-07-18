import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import '../../providers/assessment/assessment_provider.dart';
import '../../providers/grading/grading_provider.dart';
import '../../services/calculation/course_calculation_service.dart';

class CourseTargetsCard extends ConsumerWidget {
  const CourseTargetsCard({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final repository = ref.watch(
      gradingComponentRepositoryProvider,
    );

    final assessmentAsync = ref.watch(
      assessmentEntriesProvider(
        course.id,
      ),
    );

    return StreamBuilder(
      stream: repository.watchCourseComponents(
        course.id,
      ),
      builder: (
          context,
          gradingSnapshot,
          ) {

        if (!gradingSnapshot.hasData) {
          return _loading();
        }

        final components =
        gradingSnapshot.data!;

        return assessmentAsync.when(

          loading: _loading,

          error: (_, __) => _error(),

          data: (assessments) {

            final summary =
            CourseCalculationService
                .calculate(
              components: components,
              assessments: assessments,
            );

            return Card(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  20,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [

                    Text(
                      'Required Score Calculator',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    if (summary.remainingComponents.length > 1)

                      _InformationCard(
                        icon: Icons.auto_awesome_outlined,
                        title:
                        'More information required',
                        message:
                        'There are ${summary.remainingComponents.length} assessments without an Actual or Expected result.\n\n'
                            'Add an Expected score for all but one remaining assessment to unlock personalised score predictions.',
                      )

                    else if (summary.remainingComponents.isEmpty)

                      _InformationCard(
                        icon:
                        Icons.check_circle_outline,
                        title:
                        'Everything has been graded',
                        message:
                        'There are no remaining assessments to calculate.',
                      )

                    else ...[

                        if (course.targetScore != null)

                          _ScoreRequirementCard(
                            title: 'Target Score',
                            icon: Icons.flag_outlined,
                            target: course.targetScore!,
                            requiredScore:
                            summary.requiredPercentageFor(
                              course.targetScore!,
                            )!,
                            component:
                            summary
                                .remainingTarget!
                                .component
                                .name,
                            achievable:
                            summary.isAchievable(
                              course.targetScore!,
                            ),
                            maximumPossible:
                            summary
                                .maximumPossiblePercentage,
                          ),

                        if (course.targetScore != null)
                          const SizedBox(height: 16),

                        if (course
                            .minimumAcceptableScore !=
                            null)

                          _ScoreRequirementCard(
                            title:
                            'Minimum Acceptable',
                            icon:
                            Icons.thumb_up_outlined,
                            target:
                            course
                                .minimumAcceptableScore!,
                            requiredScore:
                            summary.requiredPercentageFor(
                              course
                                  .minimumAcceptableScore!,
                            )!,
                            component:
                            summary
                                .remainingTarget!
                                .component
                                .name,
                            achievable:
                            summary.isAchievable(
                              course
                                  .minimumAcceptableScore!,
                            ),
                            maximumPossible:
                            summary
                                .maximumPossiblePercentage,
                          ),

                        if (course
                            .minimumAcceptableScore !=
                            null)
                          const SizedBox(height: 16),

                        _ScoreRequirementCard(
                          title: 'Passing Score',
                          icon:
                          Icons.school_outlined,
                          target:
                          course.passingScore,
                          requiredScore:
                          summary.requiredPercentageFor(
                            course.passingScore,
                          )!,
                          component:
                          summary
                              .remainingTarget!
                              .component
                              .name,
                          achievable:
                          summary.isAchievable(
                            course.passingScore,
                          ),
                          maximumPossible:
                          summary
                              .maximumPossiblePercentage,
                        ),
                      ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _loading() =>
      const Card(
        child: Padding(
          padding:
          EdgeInsets.all(32),
          child: Center(
            child:
            CircularProgressIndicator(),
          ),
        ),
      );

  static Widget _error() =>
      const Card(
        child: Padding(
          padding:
          EdgeInsets.all(24),
          child: Text(
            'Unable to load analytics.',
          ),
        ),
      );
}

class _InformationCard
    extends StatelessWidget {

  const _InformationCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;

  final String title;

  final String message;

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Icon(
            icon,
            size: 32,
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),

          const SizedBox(
            height: 8,
          ),

          Text(message),
        ],
      ),
    );
  }
}

class _ScoreRequirementCard
    extends StatelessWidget {

  const _ScoreRequirementCard({
    required this.title,
    required this.icon,
    required this.target,
    required this.requiredScore,
    required this.component,
    required this.achievable,
    required this.maximumPossible,
  });

  final String title;

  final IconData icon;

  final double target;

  final double requiredScore;

  final String component;

  final bool achievable;

  final double maximumPossible;

  @override
  Widget build(BuildContext context) {

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                Icon(icon),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            if (achievable) ...[

              Text(
                '${requiredScore.toStringAsFixed(1)}%',
                style: Theme.of(
                  context,
                )
                    .textTheme
                    .displaySmall,
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'Required in $component to achieve ${target.toStringAsFixed(1)}%',
              ),
            ]

            else ...[

              Text(
                'Target no longer achievable',
                style: Theme.of(
                  context,
                )
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  color:
                  Theme.of(context)
                      .colorScheme
                      .error,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'Maximum possible: ${maximumPossible.toStringAsFixed(1)}%',
              ),
            ],
          ],
        ),
      ),
    );
  }
}