import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_design.dart';
import '../../../grades/providers/semester/semester_statistics_provider.dart';
import '../../../grades/services/calculation/course_calculation_summary.dart';
import '../../../grades/widgets/course/course_actions.dart';
import '../../../help/widgets/help_anchor.dart';

const _maxCoursesShown = 4;

class SemesterPanel extends StatelessWidget {
  const SemesterPanel({
    required this.semesterName,
    required this.courses,
  });

  final String? semesterName;
  final List<SemesterCoursePriority> courses;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final shown = courses.take(_maxCoursesShown).toList();
    final remaining = courses.length - shown.length;

    return ScholarPanel(
      onTap: () => context.go('/grades'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScholarSectionHeader(
            title: 'This Semester',
            subtitle: semesterName ?? 'No semester selected',
          ),
          const Gap(14),
          if (courses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Add courses and a grading structure to see your standing here.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                    ),
              ),
            )
          else ...[
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const Gap(8),
              _CourseRow(priority: shown[i], isFirst: i == 0),
            ],
            if (remaining > 0) ...[
              const Gap(10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/grades'),
                  child: Text('View all ($remaining more)'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({required this.priority, required this.isFirst});

  final SemesterCoursePriority priority;

  /// Only the first shown row registers the `course-standing-chip` help
  /// anchor — anchor ids must be unique per page, and this chip repeats
  /// once per course, so we spotlight one concrete example rather than
  /// every instance.
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final summary = priority.summary;
    final effectiveTarget =
        priority.course.targetScore ?? priority.course.passingScore;
    final standing = _standingFor(context, summary, effectiveTarget);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => CourseActions.open(context, priority.course),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.panelStrong.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: palette.stroke.withValues(alpha: 0.72)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priority.course.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Gap(3),
                    Text(
                      !summary.hasAnyScores
                          ? 'No scores recorded yet'
                          : summary.isFullyForecasted
                              ? 'Projected ${summary.projectedPercentage.toStringAsFixed(0)}%'
                              : 'Up to ${summary.maximumPossiblePercentage.toStringAsFixed(0)}% possible',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              isFirst
                  ? HelpAnchor(
                      pageId: '/home',
                      anchorId: 'course-standing-chip',
                      child: _StandingChip(
                        label: standing.$1,
                        color: standing.$2,
                      ),
                    )
                  : _StandingChip(label: standing.$1, color: standing.$2),
            ],
          ),
        ),
      ),
    );
  }

  static (String, Color) _standingFor(
    BuildContext context,
    CourseCalculationSummary summary,
    double target,
  ) {
    final palette = context.scholarPalette;

    if (!summary.hasAnyScores) {
      return ('No data yet', palette.textMuted);
    }

    if (!summary.isAchievable(target)) {
      return ('At risk', Theme.of(context).colorScheme.error);
    }

    // Only call out "Needs work" once every component has a score to
    // forecast from. Otherwise projectedPercentage understates courses
    // that still have real, untouched opportunity remaining, and a
    // partial forecast being below target doesn't mean the course is
    // off track — isAchievable already confirmed the target is still
    // reachable above.
    if (summary.isFullyForecasted &&
        summary.projectedPercentage < target) {
      return ('Needs work', palette.warning);
    }

    return ('On track', palette.success);
  }
}

class _StandingChip extends StatelessWidget {
  const _StandingChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
