import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../../grades/widgets/sections/semester/hidden_section.dart';
import '../domain/countdown_item.dart';
import '../providers/countdown_provider.dart';
import '../widgets/sections/completed_section.dart';
import '../widgets/sections/active_section.dart';
import 'countdown_crud_screen.dart';

class CountdownScreen extends ConsumerWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdownsAsync = ref.watch(countdownsProvider);
    final upcoming = ref.watch(upcomingCountdownsProvider);
    final userId = ref.watch(authStateProvider).valueOrNull?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.event_note_outlined),
            label: 'New Countdown',
            onTap: userId == null
                ? null
                : () => _openCountdownCrud(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: countdownsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Unable to load countdowns: $error'),
          ),
          data: (items) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScholarSectionHeader(
                        title: 'Countdown',
                        subtitle:
                        'Track exams, assessments, and important deadlines',
                      ),
                      const Gap(16),
                      _CountdownSummary(items: items),
                      const Gap(16),
                      if (items.isEmpty)
                        const _EmptyCountdowns()
                      else
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ActiveSection(),
                            CompletedSection(),
                            HiddenSection(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}

class _CountdownSummary extends StatelessWidget {
  const _CountdownSummary({required this.items});

  final List<CountdownItem> items;

  @override
  Widget build(BuildContext context) {
    final active = items.where((item) => !item.isCompleted).toList();
    final urgent = active.where((item) => item.daysRemaining <= 3).length;
    final exams = active
        .where(
          (item) =>
              item.type == CountdownType.midterm ||
              item.type == CountdownType.finalExamination,
        )
        .length;

    return ScholarPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final tiles = [
            _SummaryTile(
              icon: Icons.event_available_rounded,
              label: 'Active',
              value: '${active.length}',
            ),
            _SummaryTile(
              icon: Icons.priority_high_rounded,
              label: 'Urgent',
              value: '$urgent',
            ),
            _SummaryTile(
              icon: Icons.school_outlined,
              label: 'Exams',
              value: '$exams',
            ),
          ];

          if (narrow) {
            return Column(
              children: [
                for (final tile in tiles) ...[
                  tile,
                  if (tile != tiles.last) const Gap(10),
                ],
              ],
            );
          }

          return Row(
            children: [
              for (final tile in tiles) ...[
                Expanded(child: tile),
                if (tile != tiles.last) const Gap(10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.panelStrong.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.stroke),
      ),
      child: Row(
        children: [
          ScholarIconBadge(icon: icon, size: 38),
          const Gap(12),
          Column(
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
        ],
      ),
    );
  }
}

class _EmptyCountdowns extends StatelessWidget {
  const _EmptyCountdowns();

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return ScholarPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          ScholarIconBadge(
            icon: Icons.event_note_outlined,
            color: palette.brandStart,
            size: 54,
          ),
          const Gap(14),
          Text(
            'No countdowns yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Gap(6),
          Text(
            'Create your first exam or deadline countdown.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openCountdownCrud(
  BuildContext context, {
  CountdownItem? initial,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CountdownCrudScreen(initial: initial),
    ),
  );
}