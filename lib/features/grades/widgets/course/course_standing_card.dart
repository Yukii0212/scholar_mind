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

                Text(
                  'Current Standing',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              summary.hasScores
                  ? 'You have currently secured '
                  '${summary.guaranteedPercentage.toStringAsFixed(1)}% '
                  'of your final course grade.'
                  : 'No assessment scores have been entered yet.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(height: 8),

            Text(
              summary.hasScores
                  ? 'You have completed '
                  '${summary.completedWeight.toStringAsFixed(0)}% '
                  'of the course assessment.\n\n'
                  'If you obtain full marks for every remaining assessment, '
                  'your highest possible final score will be '
                  '${summary.maximumPossiblePercentage.toStringAsFixed(1)}%.'
                  : 'Once you begin entering your actual scores, '
                  'ScholarMind will automatically analyse your progress and '
                  'calculate your highest possible final score.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}