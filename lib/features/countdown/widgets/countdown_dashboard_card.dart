import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_design.dart';
import '../domain/countdown_item.dart';
import '../providers/countdown_provider.dart';
import '../screens/countdown_crud_screen.dart';

class CountdownDashboardCard extends ConsumerWidget {
  const CountdownDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.scholarPalette;
    final upcoming = ref.watch(upcomingCountdownsProvider);
    final featured = upcoming.take(3).toList();

    return ScholarPanel(
      onTap: () => context.go('/countdown'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScholarSectionHeader(
            title: 'Exam Countdown',
            subtitle: featured.isEmpty
                ? 'No upcoming deadlines'
                : '${featured.length} priority countdowns',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: palette.textMuted,
            ),
          ),
          const Gap(14),
          if (featured.isEmpty)
            _EmptyCountdown(palette: palette)
          else
            Column(
              children: [
                for (final item in featured) ...[
                  _CountdownPreview(
                    item: item,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CountdownCrudScreen(
                            initial: item,
                          ),
                        ),
                      );
                    },
                  ),
                  if (item != featured.last) const Gap(10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _CountdownPreview extends StatelessWidget {
  const _CountdownPreview({
    required this.item,
    required this.onTap,
  });

  final CountdownItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final days = item.daysRemaining;
    final isUrgent = days <= 3;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.panelStrong.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isUrgent
                  ? palette.warning.withValues(alpha: 0.52)
                  : palette.stroke.withValues(alpha: 0.72),
            ),
          ),
          child: Row(
            children: [
              ScholarIconBadge(
                icon: _iconFor(item.type),
                size: 36,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(3),
                    Text(
                      '${item.type.label} • ${item.priority.priorityLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(10),
              Text(
                _daysText(days),
                textAlign: TextAlign.right,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                  color: isUrgent
                      ? palette.warning
                      : palette.brandEnd,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCountdown extends StatelessWidget {
  const _EmptyCountdown({required this.palette});

  final ScholarPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.panelStrong.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.stroke.withValues(alpha: 0.66)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available_rounded, color: palette.success),
          const Gap(10),
          Expanded(
            child: Text(
              'Add exams and deadlines to keep the week visible.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(CountdownType type) {
  return switch (type) {
    CountdownType.assignment => Icons.assignment_outlined,
    CountdownType.quiz => Icons.quiz_outlined,
    CountdownType.lab => Icons.science_outlined,
    CountdownType.presentation => Icons.co_present_outlined,
    CountdownType.project => Icons.account_tree_outlined,
    CountdownType.midterm => Icons.school_outlined,
    CountdownType.finalExamination => Icons.event_note_outlined,
    CountdownType.personal => Icons.bookmark_outline_rounded,
    CountdownType.other => Icons.event_outlined,
  };
}

String _daysText(int days) {
  if (days < 0) return 'Overdue';
  if (days == 0) return 'Today';
  if (days == 1) return '1 day';
  return '$days days';
}
