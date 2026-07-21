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
            child: CircularProgressIndicator(),
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
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(
              20,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Course Overview',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge,
                ),

                const SizedBox(
                  height: 20,
                ),


                Text(
                  'Marks Needed',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium,
                ),

                const SizedBox(
                  height: 5,
                ),

                if (courses.isEmpty)
                  const Text(
                    'No courses available.',
                  )
                else
                  ...courses.map(
                        (course) {
                      final target =
                          course.course.targetScore;

                      if (target == null) {
                        return ListTile(
                          contentPadding:
                          EdgeInsets.zero,
                          title: Text(
                            course.course.name,
                          ),
                          subtitle: const Text(
                            'No target grade set.',
                          ),
                        );
                      }

                      final achievable =
                      course.summary.isAchievable(
                        target,
                      );

                      final required =
                      course.summary
                          .requiredPercentageFor(
                        target,
                      );

                      final remainingTarget = course.summary.remainingTarget;

                      String subtitle;

                      if (!achievable) {
                        subtitle = 'Target is no longer achievable.';
                      } else if (required == null || remainingTarget == null) {
                        subtitle = 'No remaining assessments.';
                      } else {
                        subtitle =
                        'Need ${required.toStringAsFixed(1)}% in ${remainingTarget.component.name}';
                      }

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(course.course.name),
                        subtitle: Text(subtitle),
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