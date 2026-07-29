import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_design.dart';
import '../../../help/widgets/help_anchor.dart';
import '../../data/models/course_model.dart';
import '../../help/course_analytics_preview_provider.dart';
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
    final repository = ref.watch(gradingComponentRepositoryProvider);
    final assessmentAsync = ref.watch(assessmentEntriesProvider(course.id));

    return StreamBuilder(
      stream: repository.watchCourseComponents(course.id),
      builder: (context, gradingSnapshot) {
        if (!gradingSnapshot.hasData) {
          return _loading();
        }

        final components = gradingSnapshot.data!;

        return assessmentAsync.when(
          loading: _loading,
          error: (_, __) => _error(),
          data: (assessments) {
            final summary = CourseCalculationService.calculate(
              components: components,
              assessments: assessments,
            );

            final showRequiredScorePreview =
                !summary.canCalculateRequiredScore &&
                    ref.watch(courseAnalyticsRequiredScorePreviewProvider);

            return ScholarPanel(
              child: HelpAnchor(
                pageId: 'course-analytics',
                anchorId: 'required-score-calculator',
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScholarSectionHeader(
                    title: 'Required Score Calculator',
                    subtitle: 'One remaining assessment prediction',
                  ),
                  const Gap(18),
                  if (!summary.canCalculateRequiredScore)
                    if (showRequiredScorePreview)
                      // No real calculation available for this course yet,
                      // but the help tutorial still needs something to
                      // point at — show one illustrative, non-interactive
                      // example instead of silently having nothing here.
                      // See `course_analytics_preview_provider.dart`.
                      const _ScoreRequirementCard(
                        title: 'Target Score',
                        icon: Icons.flag_outlined,
                        target: 80,
                        requiredScore: 92.3,
                        component: 'Finals',
                        achievable: true,
                        maximumPossible: 100,
                        isExample: true,
                      )
                    else
                      _InformationCard(
                        icon: Icons.auto_awesome_outlined,
                        title: summary.remainingTargets.isEmpty
                            ? 'No open assessment to calculate'
                            : 'More information required',
                        message: summary.remainingTargets.isEmpty
                            ? 'Leave one assessment without an Actual or Expected score to calculate what you need there.'
                            : 'Add Expected scores for all but one remaining assessment to unlock personalized predictions.',
                      )
                  else ...[
                    if (course.targetScore != null)
                      _ScoreRequirementCard(
                        title: 'Target Score',
                        icon: Icons.flag_outlined,
                        target: course.targetScore!,
                        requiredScore: summary.requiredPercentageFor(
                          course.targetScore!,
                        )!,
                        component:
                            summary.remainingTarget?.component.name ?? '',
                        achievable: summary.isAchievable(course.targetScore!),
                        maximumPossible: summary.maximumPossiblePercentage,
                      ),
                    if (course.targetScore != null) const Gap(12),
                    if (course.minimumAcceptableScore != null)
                      _ScoreRequirementCard(
                        title: 'Minimum Acceptable',
                        icon: Icons.thumb_up_outlined,
                        target: course.minimumAcceptableScore!,
                        requiredScore: summary.requiredPercentageFor(
                          course.minimumAcceptableScore!,
                        )!,
                        component:
                            summary.remainingTarget?.component.name ?? '',
                        achievable: summary.isAchievable(
                          course.minimumAcceptableScore!,
                        ),
                        maximumPossible: summary.maximumPossiblePercentage,
                      ),
                    if (course.minimumAcceptableScore != null) const Gap(12),
                    _ScoreRequirementCard(
                      title: 'Passing Score',
                      icon: Icons.school_outlined,
                      target: course.passingScore,
                      requiredScore:
                          summary.requiredPercentageFor(course.passingScore)!,
                      component: summary.remainingTarget?.component.name ?? '',
                      achievable: summary.isAchievable(course.passingScore),
                      maximumPossible: summary.maximumPossiblePercentage,
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

  static Widget _loading() => const ScholarPanel(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );

  static Widget _error() => const ScholarPanel(
        padding: EdgeInsets.all(24),
        child: Text('Unable to load analytics.'),
      );
}

class _InformationCard extends StatelessWidget {
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
    final palette = context.scholarPalette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.panelStrong.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: palette.brandEnd, size: 28),
          const Gap(12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const Gap(6),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRequirementCard extends StatelessWidget {
  const _ScoreRequirementCard({
    required this.title,
    required this.icon,
    required this.target,
    required this.requiredScore,
    required this.component,
    required this.achievable,
    required this.maximumPossible,
    this.isExample = false,
  });

  final String title;
  final IconData icon;
  final double target;
  final double requiredScore;
  final String component;
  final bool achievable;
  final double maximumPossible;
  final bool isExample;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.panelStrong.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: achievable
              ? palette.brandStart.withValues(alpha: 0.82)
              : Theme.of(context).colorScheme.error.withValues(alpha: 0.86),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: palette.brandEnd),
              const Gap(10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (isExample) ...[
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Example',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(8),
              // The goal itself, so "Target Score" reads as a labeled pair
              // right here — the big number below is never mistaken for
              // this value, since it's a different question entirely
              // (what's needed on the one assessment left, not the goal).
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (achievable
                          ? palette.brandStart
                          : Theme.of(context).colorScheme.error)
                      .withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${target.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: achievable
                            ? palette.brandEnd
                            : Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            ],
          ),
          const Gap(16),
          if (achievable) ...[
            Text(
              'Needed in $component',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
            ),
            const Gap(2),
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${requiredScore.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              'No longer achievable',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const Gap(6),
            Text(
              'Maximum possible: ${maximumPossible.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
