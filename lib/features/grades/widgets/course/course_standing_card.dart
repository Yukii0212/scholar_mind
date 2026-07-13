import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_mind/features/grades/services/calculation/course_calculation_service.dart';

import '../../data/models/grading_component_model.dart';
import '../../providers/assessment/assessment_provider.dart';

class CurrentStandingCard
    extends ConsumerWidget {
  const CurrentStandingCard({
    super.key,
    required this.courseId,
    required this.components,
  });

  final String courseId;

  final List<GradingComponentModel>
  components;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {

    final assessments =
        ref.watch(
          assessmentEntriesProvider(
            courseId,
          ),
        );
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
          components: components,
          assessments: entries,
        );

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

            Row(
              children: [

                Expanded(
                  child: TextFormField(
                    initialValue: '80',
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Target Score',
                      suffixText: '%',
                    ),
                    keyboardType:
                    const TextInputType
                        .numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: TextFormField(
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Minimum Acceptable',
                      suffixText: '%',
                      hintText: 'Optional',
                    ),
                    keyboardType:
                    const TextInputType
                        .numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

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

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  '${summary.maximumPossiblePercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),

                const SizedBox(height: 4),

                Text(
                  'Remaining Opportunity: '
                      '${summary.remainingOpportunity.toStringAsFixed(1)}%',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
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
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
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
        ),
      ),
    );
      },
    );
  }
}