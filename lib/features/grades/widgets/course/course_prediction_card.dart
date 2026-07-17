import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import '../../providers/assessment/assessment_provider.dart';
import '../../providers/grading/grading_provider.dart';
import '../../services/calculation/course_calculation_service.dart';
import '../../services/calculation/course_calculation_summary.dart';

class CoursePredictionCard extends ConsumerWidget {
  const CoursePredictionCard({
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
            CourseCalculationService.calculate(
              components: components,
              assessments: assessments,
            );

            if (!summary.canCalculateRequiredScore ||
                course.targetScore == null) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Predictions become available when only one assessment remains.',
                  ),
                ),
              );
            }

            final predictions =
            summary.predictionTableFor(
              course.targetScore!,
            );

            return Card(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Outcome Predictions',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'See how different scores in ${summary.remainingTarget!.component.name} affect your final course grade.',
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: const [

                        Expanded(
                          child: Text(
                            'Assessment',
                            style: TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            'Final Grade',
                            textAlign:
                            TextAlign.end,
                            style: TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(),

                    ...predictions.map(
                          (prediction) =>
                          _PredictionRow(
                            prediction:
                            prediction,
                          ),
                    ),
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
            'Unable to load predictions.',
          ),
        ),
      );
}

class _PredictionRow
    extends StatelessWidget {

  const _PredictionRow({
    required this.prediction,
  });

  final CourseCalculationPrediction
  prediction;

  @override
  Widget build(BuildContext context) {

    final highlight =
        prediction.isHighlighted;

    return Container(
      margin:
      const EdgeInsets.symmetric(
        vertical: 3,
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? Theme.of(context)
            .colorScheme
            .primaryContainer
            : null,
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Row(
        children: [

          Expanded(
            child: Text(
              '${prediction.assessmentPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: highlight
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),

          Expanded(
            child: Text(
              '${prediction.finalPercentage.toStringAsFixed(1)}%',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: highlight
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}