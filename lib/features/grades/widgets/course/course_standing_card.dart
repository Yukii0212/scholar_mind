import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_mind/features/grades/services/calculation/course_calculation_service.dart';

import '../../../help/widgets/help_anchor.dart';
import '../../data/models/course_model.dart';
import '../../data/models/grading_component_model.dart';
import '../../providers/assessment/assessment_provider.dart';
import '../../providers/course/course_provider.dart';

class CurrentStandingCard extends ConsumerStatefulWidget {
  const CurrentStandingCard({
    super.key,
    required this.course,
    required this.courseId,
    required this.components,
  });

  final CourseModel course;

  final String courseId;

  final List<GradingComponentModel> components;

  @override
  ConsumerState<CurrentStandingCard> createState() =>
      _CurrentStandingCardState();
}

class _CurrentStandingCardState extends ConsumerState<CurrentStandingCard> {
  late final TextEditingController _targetController;

  late final TextEditingController _minimumController;

  late final TextEditingController _passingController;

  @override
  void initState() {
    super.initState();

    _targetController = TextEditingController();

    _minimumController = TextEditingController();

    _passingController = TextEditingController();
  }

  @override
  void dispose() {
    _targetController.dispose();
    _minimumController.dispose();
    _passingController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final assessments = ref.watch(
      assessmentEntriesProvider(
        widget.courseId,
      ),
    );

    final liveCourse = ref.watch(
      courseProvider(
        widget.courseId,
      ),
    );

    return liveCourse.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const SizedBox(),
      data: (course) {
        return assessments.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const SizedBox(),
          data: (entries) {
            final summary = CourseCalculationService.calculate(
              components: widget.components,
              assessments: entries,
            );

            final targetText = course.targetScore?.toStringAsFixed(0) ?? '';

            if (_targetController.text != targetText) {
              _targetController.text = targetText;
            }

            final minimumText =
                course.minimumAcceptableScore?.toStringAsFixed(0) ?? '';

            if (_minimumController.text != minimumText) {
              _minimumController.text = minimumText;
            }

            final passingText = course.passingScore.toStringAsFixed(0);

            if (_passingController.text != passingText) {
              _passingController.text = passingText;
            }

            return Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Current Standing',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          HelpAnchor(
                            pageId: 'course-detail',
                            anchorId: 'target-score-field',
                            child: TextFormField(
                            controller: _targetController,
                            decoration: const InputDecoration(
                              labelText: 'Target Score',
                              suffixText: '%',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onFieldSubmitted: (_) async {
                              final repository = ref.read(
                                courseRepositoryProvider,
                              );

                              final value = double.tryParse(
                                _targetController.text,
                              );

                              if (value != null && (value < 0 || value > 100)) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Target Score must be between 0% and 100%.',
                                    ),
                                  ),
                                );

                                _targetController.text =
                                    course.targetScore?.toStringAsFixed(0) ?? '';

                                return;
                              }

                              await repository.updateCourse(
                                course.copyWith(
                                  targetScore: value,
                                ),
                              );
                            },
                            ),
                          ),
                          const SizedBox(height: 16),
                          HelpAnchor(
                            pageId: 'course-detail',
                            anchorId: 'minimum-acceptable-field',
                            child: TextFormField(
                            controller: _minimumController,
                            decoration: const InputDecoration(
                              labelText: 'Minimum Acceptable',
                              hintText: 'Optional',
                              suffixText: '%',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onFieldSubmitted: (_) async {
                              final repository = ref.read(
                                courseRepositoryProvider,
                              );

                              final value =
                                  _minimumController.text.trim().isEmpty
                                      ? null
                                      : double.tryParse(
                                          _minimumController.text,
                                        );

                              if (value != null && (value < 0 || value > 100)) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Minimum Acceptable score must be between 0% and 100%.',
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
                                  minimumAcceptableScore: value,
                                ),
                              );
                            },
                            ),
                          ),
                          const SizedBox(height: 16),
                          HelpAnchor(
                            pageId: 'course-detail',
                            anchorId: 'passing-score-field',
                            child: TextFormField(
                            controller: _passingController,
                            decoration: const InputDecoration(
                              labelText: 'Passing Score',
                              suffixText: '%',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onFieldSubmitted: (_) async {
                              final repository = ref.read(
                                courseRepositoryProvider,
                              );

                              final value = double.tryParse(
                                _passingController.text,
                              );

                              if (value == null ||
                                  value < 0 ||
                                  value > 100) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Passing Score must be between 0% and 100%.',
                                    ),
                                  ),
                                );

                                _passingController.text =
                                    course.passingScore.toStringAsFixed(0);

                                return;
                              }

                              await repository.updateCourse(
                                course.copyWith(
                                  passingScore: value,
                                ),
                              );
                            },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: summary.guaranteedPercentage / 100,
                        ),
                        const SizedBox(height: 12),
                        HelpAnchor(
                          pageId: 'course-detail',
                          anchorId: 'guaranteed-score',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Score',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Text(
                                '${summary.guaranteedPercentage.toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (summary.expectedEntries.isNotEmpty) ...[
                          LinearProgressIndicator(
                            value: summary.projectedPercentage / 100,
                          ),
                          const SizedBox(height: 12),
                          HelpAnchor(
                            pageId: 'course-detail',
                            anchorId: 'projected-score',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Projected Score',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                                Text(
                                  '${summary.projectedPercentage.toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        LinearProgressIndicator(
                          value: summary.maximumPossiblePercentage / 100,
                        ),
                        const SizedBox(height: 12),
                        HelpAnchor(
                          pageId: 'course-detail',
                          anchorId: 'maximum-achievable',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Maximum Achievable Score',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Text(
                                '${summary.maximumPossiblePercentage.toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        HelpAnchor(
                          pageId: 'course-detail',
                          anchorId: 'progress-towards-goal',
                          child: Builder(
                          builder: (context) {
                            // When no personal Target Score has been set,
                            // fall back to the course's Passing Score so
                            // this card always tracks progress against a
                            // real threshold instead of showing nothing.
                            final effectiveTarget =
                                course.targetScore ?? course.passingScore;

                            final usingPassingFallback =
                                course.targetScore == null;

                            final fullyForecasted =
                                summary.isFullyForecasted;

                            final targetAchieved = summary.guaranteedPercentage >=
                                effectiveTarget;

                            final projectedOnTrack =
                                summary.projectedPercentage >= effectiveTarget;

                            final targetStillPossible = summary.isAchievable(
                              effectiveTarget,
                            );

                            late final Color borderColor;

                            late final IconData icon;

                            late final String message;

                            if (targetAchieved) {
                              borderColor = Colors.green;

                              icon = Icons.verified;

                              message = usingPassingFallback
                                  ? 'Congratulations! You have already secured enough to pass this course.'
                                  : 'Congratulations! You have already achieved your target score.';
                            } else if (fullyForecasted) {
                              if (projectedOnTrack) {
                                borderColor = Colors.green;

                                icon = Icons.check_circle;

                                message = usingPassingFallback
                                    ? 'Based on your expected scores, you are currently on track to pass this course.'
                                    : 'Based on your expected scores, you are currently on track to achieve your target score.';
                              } else if (targetStillPossible) {
                                borderColor = Colors.amber;

                                icon = Icons.warning_amber_rounded;

                                message = usingPassingFallback
                                    ? 'Based on your expected scores, you are currently below the passing threshold.\n\n'
                                        'You will need to outperform your expected scores to pass this course.'
                                    : 'Based on your expected scores, you are currently below your target score.\n\n'
                                        'You will need to outperform your expected scores to reach your goal.';
                              } else {
                                borderColor = Colors.red;

                                icon = Icons.cancel_outlined;

                                message = usingPassingFallback
                                    ? 'Even with perfect scores from the remaining assessments, '
                                        'you will not be able to pass this course.'
                                    : 'Even with perfect scores from the remaining assessments, '
                                        'your target score is no longer achievable.';
                              }
                            } else {
                              if (targetStillPossible) {
                                borderColor = Colors.green;

                                icon = Icons.check_circle;

                                message = usingPassingFallback
                                    ? 'Passing this course is still achievable.'
                                    : 'Your target score is still achievable.';
                              } else {
                                borderColor = Colors.red;

                                icon = Icons.cancel_outlined;

                                message = usingPassingFallback
                                    ? 'Passing this course is no longer achievable.'
                                    : 'Your target score is no longer achievable.';
                              }
                            }

                            return Card(
                              elevation: 0,
                              color: Theme.of(context).colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: borderColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(icon),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Progress Towards Goal',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(message),
                                          if (!targetAchieved) ...[
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        fullyForecasted
                                                            ? 'Projected Final Score'
                                                            : 'Maximum Achievable',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelMedium,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        fullyForecasted
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        usingPassingFallback
                                                            ? 'Passing Score'
                                                            : 'Target Score',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelMedium,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '${effectiveTarget.toStringAsFixed(1)}%',
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
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (summary.completedComponents.isNotEmpty) ...[
                              Text(
                                "You've already received results for:",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              ...summary.completedComponents.map(
                                (component) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 4,
                                  ),
                                  child: Text(
                                    '✓ ${component.name}',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (summary.expectedComponents.isNotEmpty) ...[
                              Text(
                                "You're expecting:",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              ...summary.expectedComponents.map(
                                (component) {
                                  final entry =
                                      summary.expectedEntries.firstWhere(
                                    (e) => e.componentId == component.id,
                                  );

                                  return Padding(
                                    padding: const EdgeInsets.only(
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
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    summary.remainingComponents.isEmpty
                                        ? 'If your expected scores are accurate, '
                                            'your final course score will be approximately '
                                            '${summary.projectedPercentage.toStringAsFixed(1)}%.'
                                        : 'If your expected scores are accurate, you are on pace for '
                                            '${summary.projectedPercentage.toStringAsFixed(1)}% '
                                            'from graded and expected work so far. The assessments below '
                                            'are still to be decided.',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (summary.remainingComponents.isNotEmpty) ...[
                              Text(
                                "You haven't received results for:",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              ...summary.remainingComponents.map(
                                (component) => Padding(
                                  padding: const EdgeInsets.only(
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
                                  padding: const EdgeInsets.all(16),
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
                              const SizedBox(height: 16),
                            ],
                            if (!summary.hasAnyScores &&
                                summary.remainingComponents.isEmpty)
                              const Text(
                                'Start by entering the marks you have already received.',
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
