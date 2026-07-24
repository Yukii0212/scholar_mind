import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/countdown_item.dart';
import '../providers/countdown_provider.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: userId == null ? null : () => _openCountdownCrud(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Countdown'),
      ),
      body: SafeArea(
        top: false,
        child: countdownsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Unable to load countdowns: $error'),
          ),
          data: (items) {
            final completed = items.where((item) => item.isCompleted).toList();

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
                        Column(
                          children: [
                            for (final item in [
                              ...upcoming,
                              ...completed,
                            ]) ...[
                              _CountdownCard(
                                item: item,
                                onToggle: userId == null
                                    ? null
                                    : (completed) =>
                                    ref
                                        .read(countdownRepositoryProvider)
                                        .markCompleted(
                                      userId: userId,
                                      countdownId: item.id,
                                      completed: completed,
                                    ),
                                onEdit: userId == null
                                    ? null
                                    : () =>
                                    _openCountdownCrud(
                                      context,
                                      initial: item,
                                    ),
                                onDelete: userId == null
                                    ? null
                                    : () =>
                                    _deleteCountdown(
                                      context,
                                      ref,
                                      userId,
                                      item,
                                    ),
                              ),
                              if (item != items.last) const Gap(12),
                            ],
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

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final CountdownItem item;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final days = item.daysRemaining;
    final overdue = days < 0;
    final urgent = days <= 3 && !item.isCompleted;

    return ScholarPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item.isCompleted,
            onChanged:
                onToggle == null ? null : (value) => onToggle!(value ?? false),
          ),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              decoration: item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                    ),
                    _CountdownPill(
                      text: _daysText(days),
                      color: overdue ? palette.warning : palette.brandEnd,
                    ),
                  ],
                ),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _CountdownPill(
                      text: item.type.label,
                      color: palette.brandEnd,
                    ),
                    _CountdownPill(
                      text: 'Priority ${item.priority}',
                      color: urgent ? palette.warning : palette.textMuted,
                    ),
                    if (item.deadlineExtendable)
                      _CountdownPill(
                        text: overdue ? 'Extendable overdue' : 'Extendable',
                        color: overdue ? palette.warning : palette.success,
                      ),
                  ],
                ),
                if ((item.description ?? '').trim().isNotEmpty) ...[
                  const Gap(10),
                  Text(
                    item.description!.trim(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.textMuted,
                        ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit?.call();
              if (value == 'delete') onDelete?.call();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownPill extends StatelessWidget {
  const _CountdownPill({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
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

Future<void> _deleteCountdown(
  BuildContext context,
  WidgetRef ref,
  String userId,
  CountdownItem item,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete countdown?'),
      content: Text('This will remove "${item.title}" permanently.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  await ref.read(countdownRepositoryProvider).deleteCountdown(
        userId: userId,
        countdownId: item.id,
      );
}

String _daysText(int days) {
  if (days < 0) return '${days.abs()} days late';
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  return '$days days';
}
