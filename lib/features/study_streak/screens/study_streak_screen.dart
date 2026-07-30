import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/widgets/countdown/dashboard_calendar_grid.dart';
import '../domain/study_streak_summary.dart';
import '../providers/study_streak_provider.dart';

class StudyStreakScreen extends ConsumerWidget {
  const StudyStreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(studyStreakSummaryProvider);
    final accountCreated =
        ref.watch(authStateProvider).valueOrNull?.metadata.creationTime;

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
                  _StreakHero(
                    summary: summary,
                    accountCreated: accountCreated,
                  ),
                  const Gap(16),
                  _ActivityCalendar(summary: summary),
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
  const _StreakHero({
    required this.summary,
    required this.accountCreated,
  });

  final StudyStreakSummary summary;
  final DateTime? accountCreated;

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
                if (accountCreated != null) ...[
                  const Gap(4),
                  Text(
                    'Member since '
                    '${DateFormat('MMM d, yyyy').format(accountCreated!)}.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.textMuted,
                        ),
                  ),
                ],
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

class _ActivityCalendar extends StatefulWidget {
  const _ActivityCalendar({required this.summary});

  final StudyStreakSummary summary;

  @override
  State<_ActivityCalendar> createState() => _ActivityCalendarState();
}

class _ActivityCalendarState extends State<_ActivityCalendar> {
  DateTime _displayedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  final int _firstDayOfWeek = DateTime.monday;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final days = _buildCalendarDays(
      month: _displayedMonth,
      firstDayOfWeek: _firstDayOfWeek,
    );

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;

        if (velocity < -100) {
          _changeMonth(1);
        } else if (velocity > 100) {
          _changeMonth(-1);
        }
      },
      child: ScholarPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ScholarSectionHeader(
                    title: 'Activity Calendar',
                    subtitle: _monthYear(_displayedMonth),
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const Gap(14),
            Row(
              children: _weekdayHeaders().map((weekday) {
                return Expanded(
                  child: Center(
                    child: Text(
                      weekday,
                      style:
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: palette.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Gap(10),
            DashboardCalendarGrid(
              days: days,
              selectedDate: _selectedDate,
              eventCountBuilder: (date) {
                return widget.summary.dailyActivity[_dateId(date)] == true
                    ? 1
                    : 0;
              },
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
      );
    });
  }

  List<DateTime?> _buildCalendarDays({
    required DateTime month,
    required int firstDayOfWeek,
  }) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);

    final offset = (first.weekday - firstDayOfWeek + 7) % 7;

    return [
      ...List<DateTime?>.filled(offset, null),
      for (var day = 1; day <= last.day; day++)
        DateTime(month.year, month.month, day),
    ];
  }

  List<String> _weekdayHeaders() {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final start = _firstDayOfWeek - 1;

    return [
      ...labels.sublist(start),
      ...labels.sublist(0, start),
    ];
  }

  String _monthYear(DateTime date) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month]} ${date.year}';
  }

  String _dateId(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
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
