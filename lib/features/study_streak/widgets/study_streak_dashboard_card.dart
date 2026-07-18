import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_design.dart';
import '../providers/study_streak_provider.dart';

class StudyStreakDashboardCard extends ConsumerWidget {
  const StudyStreakDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.scholarPalette;
    final summary =
        ref.watch(studyStreakSummaryProvider).valueOrNull;

    return ScholarPanel(
      onTap: () => context.go('/study-streak'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScholarSectionHeader(
            title: 'Study Streak',
            subtitle: summary == null
                ? 'Loading your streak'
                : _subtitle(summary.currentStreak),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: palette.textMuted,
            ),
          ),
          const Gap(18),
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: palette.brandGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: palette.brandStart.withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StreakStat(
                      label: 'Current',
                      value: '${summary?.currentStreak ?? 0}',
                    ),
                    _StreakStat(
                      label: 'Longest',
                      value: '${summary?.longestStreak ?? 0}',
                    ),
                    _StreakStat(
                      label: 'Total',
                      value: '${summary?.totalStudyDays ?? 0}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _subtitle(int currentStreak) {
    if (currentStreak == 0) return 'Open the app to start today';
    if (currentStreak == 1) return '1 day active';
    return '$currentStreak days active';
  }
}

class _StreakStat extends StatelessWidget {
  const _StreakStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      width: 86,
      padding: const EdgeInsets.all(10),
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
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
