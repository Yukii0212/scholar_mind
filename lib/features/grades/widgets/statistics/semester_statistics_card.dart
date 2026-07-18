import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_design.dart';
import '../../providers/semester/semester_statistics_provider.dart';

class SemesterStatisticsCard extends ConsumerWidget {
  const SemesterStatisticsCard({
    super.key,
    required this.semesterId,
  });

  final String semesterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(semesterStatisticsProvider(semesterId));

    return statistics.when(
      loading: () => const ScholarPanel(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const ScholarPanel(
        padding: EdgeInsets.all(24),
        child: Text('Unable to load semester statistics.'),
      ),
      data: (courses) {
        final average = _average(courses);

        return ScholarPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScholarSectionHeader(
                title: 'Course Overview',
                subtitle: courses.isEmpty
                    ? 'Add courses to begin tracking your semester.'
                    : 'Projected performance and target pressure',
              ),
              const Gap(18),
              Row(
                children: [
                  _StatPill(
                    icon: Icons.menu_book_rounded,
                    label: 'Courses',
                    value: '${courses.length}',
                  ),
                  const Gap(10),
                  _StatPill(
                    icon: Icons.trending_up_rounded,
                    label: 'Average',
                    value: average == null ? '--' : average.toStringAsFixed(1),
                  ),
                ],
              ),
              const Gap(20),
              Text(
                'Marks Needed',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Gap(8),
              if (courses.isEmpty)
                Text(
                  'No courses available.',
                  style: TextStyle(color: context.scholarPalette.textMuted),
                )
              else
                ...courses.map((course) {
                  final target = course.course.targetScore;

                  if (target == null) {
                    return _CourseNeedRow(
                      name: course.course.name,
                      subtitle: 'No target grade set.',
                      progress: course.summary.completedProgress / 100,
                    );
                  }

                  final achievable = course.summary.isAchievable(target);
                  final required =
                      course.summary.requiredPercentageFor(target);

                  return _CourseNeedRow(
                    name: course.course.name,
                    subtitle: achievable
                        ? 'Need ${required!.toStringAsFixed(1)}% in ${course.summary.remainingTarget!.component.name}'
                        : 'Target is no longer achievable.',
                    progress: course.summary.completedProgress / 100,
                    warning: !achievable,
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  static double? _average(List<SemesterCoursePriority> courses) {
    if (courses.isEmpty) return null;
    final total = courses.fold<double>(
      0,
      (sum, course) => sum + course.summary.projectedPercentage,
    );
    return total / courses.length;
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.panelStrong.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: palette.stroke),
        ),
        child: Row(
          children: [
            Icon(icon, color: palette.brandEnd, size: 20),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseNeedRow extends StatelessWidget {
  const _CourseNeedRow({
    required this.name,
    required this.subtitle,
    required this.progress,
    this.warning = false,
  });

  final String name;
  final String subtitle;
  final double progress;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.panelStrong.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: palette.stroke.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Icon(
                  warning
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline_rounded,
                  color: warning ? palette.warning : palette.success,
                  size: 18,
                ),
              ],
            ),
            const Gap(5),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
            ),
            const Gap(10),
            ScholarProgressBar(value: progress),
          ],
        ),
      ),
    );
  }
}
