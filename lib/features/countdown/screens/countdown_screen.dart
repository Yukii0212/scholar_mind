import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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

class _CountdownCard extends StatefulWidget {
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
  State<_CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<_CountdownCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    final item = widget.item;

    final days = item.daysRemaining;
    final overdue = days < 0;
    final urgent = days <= 3 && !item.isCompleted;

    return ScholarPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ScholarIconBadge(

                        icon: switch (item.type) {
                          CountdownType.finalExamination =>
                          Icons.event_note_outlined,
                          CountdownType.midterm =>
                          Icons.school_outlined,
                          CountdownType.assignment =>
                          Icons.assignment_outlined,
                          CountdownType.quiz =>
                          Icons.quiz_outlined,
                          CountdownType.presentation =>
                          Icons.slideshow_outlined,
                          CountdownType.project =>
                          Icons.work_outline,
                          CountdownType.lab =>
                          Icons.science_outlined,
                          CountdownType.personal =>
                          Icons.person_outline,
                          CountdownType.other =>
                          Icons.event_outlined,
                        },
                      size: 54,
                      color: palette.brandStart
                    ),

                    const Gap(16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w900,
                              decoration: item.isCompleted
                                  ? TextDecoration
                                  .lineThrough
                                  : null,
                            ),
                          ),

                          const Gap(6),

                          Text(
                            '${item.type.label} • ${item.priority.priorityLabel}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              color:
                              palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Text(
                          _daysText(days),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            color: overdue
                                ? palette.warning
                                : palette.brandEnd,
                            fontWeight:
                            FontWeight.w900,
                          ),
                        ),

                        const Gap(8),

                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(
                            milliseconds: 200,
                          ),
                          child: Icon(
                            Icons.expand_more_rounded,
                            color: palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          ClipRect(
            child: AnimatedSize(
              duration: const Duration(
                milliseconds: 220,
              ),
              curve: Curves.easeInOut,
              child: !_expanded
                  ? const SizedBox.shrink()
                  : Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      height: 1,
                      color: palette.stroke,
                    ),

                    if ((item.description ?? '')
                        .trim()
                        .isNotEmpty) ...[
                      Text(
                        item.description!.trim(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: palette
                              .textMuted,
                        ),
                      ),

                      const Gap(16),
                    ],

                    if (item.deadlineExtendable)
                      Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child: _CountdownPill(
                          text: overdue
                              ? 'Extendable overdue'
                              : 'Extendable',
                          color: overdue
                              ? palette.warning
                              : palette.success,
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: Icon(
                          item.isCompleted
                              ? Icons.undo
                              : Icons.check,
                        ),
                        label: Text(
                          item.isCompleted
                              ? 'Mark as Active'
                              : 'Mark as Completed',
                        ),
                        onPressed:
                        widget.onToggle == null
                            ? null
                            : () => widget
                            .onToggle!(
                          !item
                              .isCompleted,
                        ),
                      ),
                    ),

                    const Gap(10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                        label:
                        const Text('Edit'),
                        onPressed:
                        widget.onEdit,
                      ),
                    ),

                    const Gap(10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.delete_outline,
                        ),
                        label: const Text(
                          'Delete',
                        ),
                        onPressed: widget.onDelete,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
