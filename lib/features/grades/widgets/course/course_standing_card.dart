import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_mind/features/grades/services/calculation/course_calculation_service.dart';

import '../../data/models/course_model.dart';
import '../../data/models/grading_component_model.dart';
import '../../providers/assessment/assessment_provider.dart';
import '../../providers/course/course_provider.dart';

class CurrentStandingCard
    extends ConsumerStatefulWidget {
  const CurrentStandingCard({
    super.key,
    required this.course,
    required this.courseId,
    required this.components,
  });

  final CourseModel course;

  final String courseId;

  final List<GradingComponentModel>
  components;

  @override
  ConsumerState<CurrentStandingCard>
  createState() =>
      _CurrentStandingCardState();
}

class _CurrentStandingCardState
    extends ConsumerState<
        CurrentStandingCard> {

  late final TextEditingController
  _targetController;

  late final TextEditingController
  _minimumController;

  @override
  void initState() {
    super.initState();

    _targetController =
        TextEditingController();

    _minimumController =
        TextEditingController();
  }

  @override
  void dispose() {
    _targetController.dispose();
    _minimumController.dispose();
    super.dispose();
  }

  Widget build(
      BuildContext context,
      ) {

    final assessments =
        ref.watch(
          assessmentEntriesProvider(
            widget.courseId,
          ),
        );

    final liveCourse =
    ref.watch(
      courseProvider(
        widget.courseId,
      ),
    );

return liveCourse.when(

loading: () =>
const Card(
child: Padding(
padding:
EdgeInsets.all(20),
child:
CircularProgressIndicator(),
),
),

error: (_, __) =>
const SizedBox(),

data: (course) {

return assessments.when(
      loading: () =>
          const Card(
            child: Padding(
              padding:
                EdgeInsets.all(20),
              child:
                CircularProgressIndicator(),
            ),
          ),
      error: (_, __) =>
          const SizedBox(),

      data: (entries) {
        final summary = CourseCalculationService.calculate(
          components: widget.components,
          assessments: entries,
        );

        final targetText =
            course.targetScore
                ?.toStringAsFixed(0) ??
                '';

        if (_targetController.text !=
            targetText) {
          _targetController.text =
              targetText;
        }

        final minimumText =
            course.minimumAcceptableScore
                ?.toStringAsFixed(0) ??
                '';

        if (_minimumController.text !=
            minimumText) {
          _minimumController.text =
              minimumText;
        }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'Current Standing',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Column(
              children: [

                TextFormField(
                  controller: _targetController,
                  decoration: const InputDecoration(
                    labelText: 'Target Score',
                    suffixText: '%',
                  ),
                  keyboardType:
                  const TextInputType
                      .numberWithOptions(
                    decimal: true,
                  ),
                  onFieldSubmitted: (_) async {

                    final repository =
                    ref.read(
                      courseRepositoryProvider,
                    );

                    final value =
                    double.tryParse(
                      _targetController.text,
                    );

                    if (value != null &&
                        value >
                            summary.totalWeight) {

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Target Score cannot exceed the maximum course score '
                                '(${summary.totalWeight.toStringAsFixed(0)}%).',
                          ),
                        ),
                      );

                      _targetController.text =
                          course.targetScore
                              ?.toStringAsFixed(0) ??
                              '';

                      return;
                    }

                    await repository.updateCourse(
                      course.copyWith(
                        targetScore: value,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _minimumController,
                  decoration: const InputDecoration(
                    labelText:
                    'Minimum Acceptable',
                    hintText: 'Optional',
                    suffixText: '%',
                  ),
                  keyboardType:
                  const TextInputType
                      .numberWithOptions(
                    decimal: true,
                  ),
                  onFieldSubmitted: (_) async {

                    final repository =
                    ref.read(
                      courseRepositoryProvider,
                    );

                    final value =
                    _minimumController.text
                        .trim()
                        .isEmpty
                        ? null
                        : double.tryParse(
                      _minimumController
                          .text,
                    );

                    if (value != null &&
                        value >
                            summary.totalWeight) {

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Minimum Acceptable cannot exceed the maximum course score '
                                '(${summary.totalWeight.toStringAsFixed(0)}%).',
                          ),
                        ),
                      );

                      _minimumController.text =
                          course.minimumAcceptableScore
                              ?.toStringAsFixed(0) ??
                              '';

                      return;
                    }

                    await repository.updateCourse(
                      course.copyWith(
                        minimumAcceptableScore:
                        value,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

        if (widget.components.isEmpty) ...[

        const SizedBox(height: 12),

          const Text(
            'Create a grading structure to unlock course analytics.',
          ),

        ] else ...[

            Text(
              summary.hasScores
                  ? 'You have currently secured '
                  '${summary.guaranteedPercentage.toStringAsFixed(1)}% '
                  'towards your final course score.'
                  : 'No assessment results have been entered yet.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(height: 28),

            LinearProgressIndicator(
              value:
              summary.guaranteedPercentage /
                  100,
            ),

            const SizedBox(height: 12),

            Text(
              'Current Score',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium,
            ),

            Text(
              '${summary.guaranteedPercentage.toStringAsFixed(1)}%',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height: 32),

          if (summary.expectedEntries.isNotEmpty) ...[

            LinearProgressIndicator(
              value:
              summary.projectedPercentage /
                  100,
            ),

            const SizedBox(height: 12),

            Text(
              'Projected Score',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium,
            ),

            Text(
              '${summary.projectedPercentage.toStringAsFixed(1)}%',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height: 32),
          ],

          LinearProgressIndicator(
            value:
            summary.maximumPossiblePercentage /
                100,
          ),

          const SizedBox(height: 12),

          Text(
            'Maximum Achievable Score',
            style: Theme.of(context)
                .textTheme
                .labelMedium,
          ),

          Text(
            '${summary.maximumPossiblePercentage.toStringAsFixed(1)}%',
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),

          const SizedBox(height: 16),

          Builder(
            builder: (context) {

              final target =
                  course.targetScore;

              final isConfigured =
                  target != null;

              final hasExpectedScores =
                  summary.expectedEntries
                      .isNotEmpty;

              final targetAchieved =
                  isConfigured &&
                      summary.guaranteedPercentage >=
                          target;

              final projectedOnTrack =
                  isConfigured &&
                      summary.projectedPercentage >=
                          target;

              final targetStillPossible =
                  isConfigured &&
                      summary.maximumPossiblePercentage >=
                          target;

              late final Color borderColor;

              late final IconData icon;

              late final String message;

              if (!isConfigured) {

                borderColor =
                    Theme.of(context)
                        .colorScheme
                        .outline;

                icon =
                    Icons.info_outline;

                message =
                'Set a Target Score to begin tracking your progress.';

              } else if (targetAchieved) {

                borderColor =
                    Colors.green;

                icon =
                    Icons.verified;

                message =
                'Congratulations! You have already achieved your target score.';

              } else if (hasExpectedScores) {

                if (projectedOnTrack) {

                  borderColor =
                      Colors.green;

                  icon =
                      Icons.check_circle;

                  message =
                  'Based on your expected scores, you are currently on track to achieve your target score.';

                } else if (targetStillPossible) {

                  borderColor =
                      Colors.amber;

                  icon =
                      Icons.warning_amber_rounded;

                  message =
                  'Based on your expected scores, you are currently below your target score.\n\n'
                      'You will need to outperform your expected scores to reach your goal.';

                } else {

                  borderColor =
                      Colors.red;

                  icon =
                      Icons.cancel_outlined;

                  message =
                  'Even with perfect scores from the remaining assessments, '
                      'your target score is no longer achievable.';
                }

              } else {

                if (targetStillPossible) {

                  borderColor =
                      Colors.green;

                  icon =
                      Icons.check_circle;

                  message =
                  'Your target score is still achievable.';

                } else {

                  borderColor =
                      Colors.red;

                  icon =
                      Icons.cancel_outlined;

                  message =
                  'Your target score is no longer achievable.';
                }
              }

              return Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .surface,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                  side: BorderSide(
                    color: borderColor,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Icon(icon),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [

                            Text(
                              'Progress Towards Goal',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),

                            const SizedBox(height: 8),

                            Text(message),

                            if (isConfigured && !targetAchieved) ...[

                              const SizedBox(height: 16),

                              Row(
                                children: [

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [

                                        Text(
                                          hasExpectedScores
                                              ? 'Projected Final Score'
                                              : 'Maximum Achievable',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          hasExpectedScores
                                              ? '${summary.projectedPercentage.toStringAsFixed(1)}%'
                                              : '${summary.maximumPossiblePercentage.toStringAsFixed(1)}%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 24),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [

                                        Text(
                                          'Target Score',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          '${target!.toStringAsFixed(1)}%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                if (summary.completedComponents
                    .isNotEmpty) ...[

                  Text(
                    "You've already received results for:",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall,
                  ),

                  const SizedBox(height: 8),

                  ...summary.completedComponents.map(
                        (component) => Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 4,
                      ),
                      child: Text(
                        '✓ ${component.name}',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],

                if (summary.expectedComponents
                    .isNotEmpty) ...[

                  Text(
                    "You're expecting:",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall,
                  ),

                  const SizedBox(height: 8),

                  ...summary.expectedComponents.map(
                        (component) {

                      final entry =
                      summary.expectedEntries
                          .firstWhere(
                            (e) =>
                        e.componentId ==
                            component.id,
                      );

                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 4,
                        ),
                        child: Text(
                          '🟣 ${component.name} '
                              '(${entry.percentage.toStringAsFixed(0)}%)',
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  Card(
                    elevation: 0,
                    child: Padding(
                      padding:
                      const EdgeInsets.all(16),
                      child: Text(
                        'If your expected scores are accurate, '
                            'your final course score will be approximately '
                            '${summary.projectedPercentage.toStringAsFixed(1)}%.',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],

                if (summary.remainingComponents
                .isNotEmpty) ...[

              Text(
                "You haven't received results for:",
                style: Theme.of(context)
                    .textTheme
                    .titleSmall,
              ),

              const SizedBox(height: 8),

              ...summary.remainingComponents.map(
                    (component) => Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Text(
                    '• ${component.name}',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                child: Padding(
                  padding:
                  const EdgeInsets.all(16),
                  child: Text(
                    'You can still earn up to '
                        '${summary.remainingOpportunity.toStringAsFixed(1)}% '
                        'from your remaining assessments.\n\n'
                        'Scoring full marks for all remaining assessments '
                        'would give you a final course score of '
                        '${summary.maximumPossiblePercentage.toStringAsFixed(1)}%.',
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],

                if (!summary.hasScores &&
                    summary.remainingComponents
                        .isEmpty)

                  Text(
                    'Start by entering the marks you have already received.',
                  ),
              ],
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
}