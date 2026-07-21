import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../domain/study_streak_summary.dart';
import '../providers/study_streak_provider.dart';

class StudyStreakScreen extends ConsumerWidget {
  const StudyStreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(studyStreakSummaryProvider);

    return SafeArea(
      top: false,
      child: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Unable to load study streak: $error'),
        ),
        data: (summary) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScholarSectionHeader(
                    title: 'Study Streak',
                    subtitle: 'Your daily ScholarMind check-in progress',
                  ),
                  const Gap(16),
                  _StreakHero(summary: summary),
                  const Gap(16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 760;
                      final activity = _MonthlyActivity(summary: summary);
                      final achievements = _Achievements(summary: summary);

                      if (narrow) {
                        return Column(
                          children: [
                            activity,
                            const Gap(16),
                            achievements,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: activity),
                          const Gap(16),
                          Expanded(child: achievements),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.summary});

  final StudyStreakSummary summary;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return ScholarPanel(
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final flame = Container(
            width: compact ? 86 : 112,
            height: compact ? 86 : 112,
            decoration: BoxDecoration(
              gradient: palette.brandGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: palette.brandStart.withValues(alpha: 0.24),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 54,
            ),
          );
          final copy = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${summary.currentStreak} day streak',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Gap(6),
                Text(
                  summary.lastStudyDate == null
                      ? 'Open ScholarMind each day to keep your streak alive.'
                      : 'Last active ${summary.lastStudyDate}.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.textMuted,
                      ),
                ),
                const Gap(16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatTile(
                      label: 'Longest',
                      value: '${summary.longestStreak}',
                    ),
                    _StatTile(
                      label: 'Total Days',
                      value: '${summary.totalStudyDays}',
                    ),
                    _StatTile(
                      label: 'Badges',
                      value: '${summary.achievements.length}',
                    ),
                  ],
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                flame,
                const Gap(18),
                Row(children: [copy]),
              ],
            );
          }

          return Row(
            children: [
              flame,
              const Gap(20),
              copy,
            ],
          );
        },
      ),
    );
  }
}

class _MonthlyActivity extends StatelessWidget {
  const _MonthlyActivity({required this.summary});

  final StudyStreakSummary summary;

  @override
  Widget build(BuildContext context) {
    final entries = summary.monthlyActivity.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final visible = entries.take(6).toList();
    final maxValue = visible
        .map((entry) => entry.value)
        .fold<int>(1, (max, value) => value > max ? value : max);

    return ScholarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScholarSectionHeader(
            title: 'Monthly Activity',
            subtitle: 'Study days recorded by month',
          ),
          const Gap(14),
          if (visible.isEmpty)
            const _EmptyLine(text: 'No activity has been recorded yet.')
          else
            Column(
              children: [
                for (final entry in visible) ...[
                  _MonthRow(
                    month: entry.key,
                    days: entry.value,
                    progress: entry.value / maxValue,
                  ),
                  if (entry != visible.last) const Gap(12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _Achievements extends StatelessWidget {
  const _Achievements({required this.summary});

  final StudyStreakSummary summary;

  @override
  Widget build(BuildContext context) {
    const thresholds = [3, 7, 14, 30, 100];

    return ScholarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScholarSectionHeader(
            title: 'Achievements',
            subtitle: 'Milestones earned from consecutive study days',
          ),
          const Gap(14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final threshold in thresholds)
                _AchievementChip(
                  days: threshold,
                  earned: summary.achievements.contains(threshold),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      width: 118,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.panelStrong.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
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
    );
  }
}

class _MonthRow extends StatelessWidget {
  const _MonthRow({
    required this.month,
    required this.days,
    required this.progress,
  });

  final String month;
  final int days;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            month,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1).toDouble(),
              minHeight: 9,
              backgroundColor: palette.panelStrong,
            ),
          ),
        ),
        const Gap(12),
        Text(
          '$days d',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: palette.textMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _AchievementChip extends StatelessWidget {
  const _AchievementChip({
    required this.days,
    required this.earned,
  });

  final int days;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: earned
            ? palette.brandStart.withValues(alpha: 0.22)
            : palette.panelStrong.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: earned ? palette.brandEnd : palette.stroke,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            earned ? Icons.workspace_premium_rounded : Icons.lock_outline,
            size: 18,
            color: earned ? palette.brandEnd : palette.textMuted,
          ),
          const Gap(8),
          Text(
            '$days days',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: earned ? palette.brandEnd : palette.textMuted,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.scholarPalette.textMuted,
          ),
    );
  }
}
