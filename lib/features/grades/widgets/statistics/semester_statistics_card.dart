import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/semester/semester_statistics_provider.dart';

class SemesterStatisticsCard extends ConsumerWidget {
  const SemesterStatisticsCard({
    super.key,
    required this.semesterId,
  });

  final String semesterId;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final statistics = ref.watch(
      semesterStatisticsProvider(
        semesterId,
      ),
    );

    return statistics.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child:
            CircularProgressIndicator(),
          ),
        ),
      ),
      error: (_, __) => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Unable to load semester statistics.',
          ),
        ),
      ),
      data: (courses) {
        final coursesWithResults = courses
            .where(
              (course) =>
          course.summary.hasScores,
        )
            .toList();

        final averageCurrentScore =
        coursesWithResults.isEmpty
            ? 0.0
            : coursesWithResults
            .map(
              (course) => course
              .summary
              .projectedPercentage,
        )
            .reduce(
              (a, b) => a + b,
        ) /
            coursesWithResults.length;

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
                  'Semester Snapshot',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _StatisticTile(
                        title: 'Courses',
                        value:
                        '${courses.length}',
                      ),
                    ),
                    Expanded(
                      child: _StatisticTile(
                        title:
                        'With Results',
                        value:
                        '${coursesWithResults.length}',
                      ),
                    ),
                    Expanded(
                      child: _StatisticTile(
                        title:
                        'Average',
                        value:
                        '${averageCurrentScore.toStringAsFixed(1)}%',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 28,
                ),
                Text(
                  'Needs Attention',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 16,
                ),
                if (courses.isEmpty)
                  const Text(
                    'No courses available.',
                  )
                else
                  ...courses.map(
                        (course) {
                      final target =
                          course
                              .course
                              .targetScore;

                      if (target == null) {
                        return const SizedBox
                            .shrink();
                      }

                      final achievable =
                      course.summary
                          .isAchievable(
                        target,
                      );

                      final required =
                      course.summary
                          .requiredPercentageFor(
                        target,
                      );

                      return ListTile(
                        contentPadding:
                        EdgeInsets.zero,
                        leading: Icon(
                          achievable
                              ? Icons
                              .warning_amber_rounded
                              : Icons
                              .cancel_outlined,
                          color: achievable
                              ? Colors.orange
                              : Colors.red,
                        ),
                        title: Text(
                          course.course.name,
                        ),
                        subtitle: Text(
                          achievable
                              ? 'Need ${required!.toStringAsFixed(1)}% in ${course.summary.remainingTarget!.component.name} to achieve your target.'
                              : 'Target is no longer achievable.',
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatisticTile
    extends StatelessWidget {
  const _StatisticTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall,
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          title,
          textAlign:
          TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .labelMedium,
        ),
      ],
    );
  }
}