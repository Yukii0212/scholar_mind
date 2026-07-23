import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/countdown_item.dart';
import '../providers/countdown_provider.dart';

class CountdownCrudScreen extends ConsumerStatefulWidget {
  const CountdownCrudScreen({
    super.key,
    this.initial,
  });

  final CountdownItem? initial;

  @override
  ConsumerState<CountdownCrudScreen> createState() =>
      _CountdownCrudScreenState();
}

enum CountdownPriorityPreset {
  low,
  normal,
  high,
  critical,
  custom,
}

class _CountdownCrudScreenState extends ConsumerState<CountdownCrudScreen> {
  final _formKey = GlobalKey<FormState>();

  static const Map<CountdownPriorityPreset, int> _presetValues = {
    CountdownPriorityPreset.low: 50,
    CountdownPriorityPreset.normal: 100,
    CountdownPriorityPreset.high: 150,
    CountdownPriorityPreset.critical: 200,
  };

  late final TextEditingController _titleController;
  late final TextEditingController _priorityController;
  late final TextEditingController _descriptionController;

  late CountdownPriorityPreset _priorityPreset;

  late CountdownType _type;
  late DateTime _dueDate;
  late bool _deadlineExtendable;

  var _saving = false;

  @override
  void initState() {
    super.initState();

    final initial = widget.initial;

    _titleController = TextEditingController(
      text: initial?.title ?? '',
    );

    final priority = initial?.priority ?? 100;

    _priorityPreset = switch (priority) {
      50 => CountdownPriorityPreset.low,
      100 => CountdownPriorityPreset.normal,
      150 => CountdownPriorityPreset.high,
      200 => CountdownPriorityPreset.critical,
      _ => CountdownPriorityPreset.custom,
    };

    _priorityController = TextEditingController(
      text: '$priority',
    );

    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );

    _type = initial?.type ?? CountdownType.finalExamination;
    _dueDate = initial?.dueDate ?? DateTime.now().add(
      const Duration(days: 7),
    );
    _deadlineExtendable = initial?.deadlineExtendable ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priorityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final isEditing = widget.initial != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Countdown' : 'Create Countdown'),
        actions: const [],
      ),
      body: ScholarScaffoldBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderPreview(
                        title: _titleController.text,
                        type: _type,
                        dueDate: _dueDate,
                        priority: int.tryParse(_priorityController.text) ?? 100,
                      ),
                      const Gap(16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final narrow = constraints.maxWidth < 760;
                          final details = _DetailsPanel(
                            titleController: _titleController,
                            priorityController: _priorityController,
                            descriptionController: _descriptionController,
                            priorityPreset: _priorityPreset,
                            onPriorityPresetChanged: (preset) {
                              setState(() {
                                _priorityPreset = preset;

                                if (preset != CountdownPriorityPreset.custom) {
                                  _priorityController.text =
                                  '${_presetValues[preset]!}';
                                }
                              });
                            },
                            onChanged: () => setState(() {}),
                          );
                          final options = _OptionsPanel(
                            type: _type,
                            dueDate: _dueDate,
                            deadlineExtendable: _deadlineExtendable,
                            onTypeChanged: (value) =>
                                setState(() => _type = value),
                            onDateChanged: (value) =>
                                setState(() => _dueDate = value),
                            onExtendableChanged: (value) =>
                                setState(() => _deadlineExtendable = value),
                          );

                          if (narrow) {
                            return Column(
                              children: [
                                details,
                                const Gap(16),
                                options,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: details),
                              const Gap(16),
                              Expanded(flex: 2, child: options),
                            ],
                          );
                        },
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.check_rounded),
                          label: Text(
                            isEditing
                                ? 'Save Changes'
                                : 'Create Countdown',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(authStateProvider).valueOrNull?.uid;
    if (userId == null) return;

    setState(() => _saving = true);
    try {
      final description = _descriptionController.text.trim();
      await ref.read(countdownRepositoryProvider).saveCountdown(
            userId: userId,
            countdownId: widget.initial?.id,
            title: _titleController.text.trim(),
            type: _type,
            priority: int.parse(_priorityController.text.trim()),
            dueDate: _dueDate,
            description: description.isEmpty ? null : description,
            deadlineExtendable: _deadlineExtendable,
          );

      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _HeaderPreview extends StatelessWidget {
  const _HeaderPreview({
    required this.title,
    required this.type,
    required this.dueDate,
    required this.priority,
  });

  final String title;
  final CountdownType type;
  final DateTime dueDate;
  final int priority;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final days = _daysRemaining(dueDate);

    return ScholarPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          ScholarIconBadge(
            icon: Icons.event_note_outlined,
            size: 58,
            color: palette.brandStart,
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.trim().isEmpty ? 'Untitled Countdown' : title.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PreviewPill(text: type.label, color: palette.brandEnd),
                    _PreviewPill(
                      text: priorityDisplay(priority),
                      color: palette.textMuted,
                    ),
                    _PreviewPill(
                      text: _daysText(days),
                      color: days <= 3 ? palette.warning : palette.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({
    required this.titleController,
    required this.priorityController,
    required this.descriptionController,
    required this.priorityPreset,
    required this.onPriorityPresetChanged,
    required this.onChanged,
  });

  final CountdownPriorityPreset priorityPreset;
  final ValueChanged<CountdownPriorityPreset> onPriorityPresetChanged;

  final TextEditingController titleController;
  final TextEditingController priorityController;
  final TextEditingController descriptionController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ScholarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScholarSectionHeader(
            title: 'Countdown Details',
            subtitle: 'Name and prioritize this deadline',
          ),
          const Gap(16),
          TextFormField(
            controller: titleController,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              labelText: 'Title',
              prefixIcon: Icon(Icons.event_note_outlined),
            ),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Enter a countdown title';
              }
              return null;
            },
          ),
          const Gap(12),
          DropdownButtonFormField<CountdownPriorityPreset>(
            initialValue: priorityPreset,
            decoration: const InputDecoration(
              labelText: 'Priority',
              prefixIcon: Icon(Icons.priority_high_rounded),
            ),
            items: const [
              DropdownMenuItem(
                value: CountdownPriorityPreset.low,
                child: Text('Low'),
              ),
              DropdownMenuItem(
                value: CountdownPriorityPreset.normal,
                child: Text('Normal'),
              ),
              DropdownMenuItem(
                value: CountdownPriorityPreset.high,
                child: Text('High'),
              ),
              DropdownMenuItem(
                value: CountdownPriorityPreset.critical,
                child: Text('Critical'),
              ),
              DropdownMenuItem(
                value: CountdownPriorityPreset.custom,
                child: Text('Custom'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onPriorityPresetChanged(value);
                onChanged();
              }
            },
          ),

          const Gap(12),

          if (priorityPreset == CountdownPriorityPreset.custom) ...[
            const Gap(12),

            TextFormField(
              controller: priorityController,
              keyboardType: TextInputType.number,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                labelText: 'Custom Priority',
                helperText: 'Higher values appear before lower values.',
                prefixIcon: Icon(Icons.tune_rounded),
              ),
              validator: (value) {
                final parsed = int.tryParse((value ?? '').trim());

                if (parsed == null || parsed < 0 || parsed > 999) {
                  return 'Enter a number from 0 to 999';
                }

                return null;
              },
            ),
          ],

          if (priorityPreset == CountdownPriorityPreset.custom) ...[
            const Gap(16),

            Text(
              'Priority Presets',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const Gap(8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text('• Low = 50')),
                      Expanded(child: Text('• High = 150')),
                    ],
                  ),

                  const Gap(6),

                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text('• Normal = 100')),
                      Expanded(child: Text('• Critical = 200')),
                    ],
                  ),

                  const Gap(14),

                  Text(
                    'Custom lets you enter any priority value.\n\n'
                        'Use a higher value to make this countdown appear higher in your countdown list.\n\n'
                        'Example:\n'
                        '• A countdown with priority 200 appears above one with priority 100.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const Gap(12),
          ],
          TextFormField(
            controller: descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsPanel extends StatelessWidget {
  const _OptionsPanel({
    required this.type,
    required this.dueDate,
    required this.deadlineExtendable,
    required this.onTypeChanged,
    required this.onDateChanged,
    required this.onExtendableChanged,
  });

  final CountdownType type;
  final DateTime dueDate;
  final bool deadlineExtendable;
  final ValueChanged<CountdownType> onTypeChanged;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<bool> onExtendableChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return ScholarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScholarSectionHeader(
            title: 'Schedule',
            subtitle: 'Type, date, and deadline behavior',
          ),
          const Gap(16),
          DropdownButtonFormField<CountdownType>(
            initialValue: type,
            decoration: const InputDecoration(
              labelText: 'Type',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: [
              for (final type in CountdownType.values)
                DropdownMenuItem(
                  value: type,
                  child: Text(type.label),
                ),
            ],
            onChanged: (value) {
              if (value != null) onTypeChanged(value);
            },
          ),
          const Gap(12),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: dueDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) onDateChanged(picked);
            },
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Due Date',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(_formatDate(dueDate)),
            ),
          ),
          const Gap(14),
          Container(
            decoration: BoxDecoration(
              color: palette.panelStrong.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.stroke),
            ),
            child: SwitchListTile(
              value: deadlineExtendable,
              onChanged: onExtendableChanged,
              title: const Text('Allow deadline extensions'),
          ),
          ),
          const Gap(8),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
                deadlineExtendable
                    ? 'The countdown stays active after the due date.'
                    : 'The countdown is completed after the due date.',
              key: ValueKey(deadlineExtendable),
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

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

int _daysRemaining(DateTime dueDate) {
  final today = DateTime.now();
  final start = DateTime(today.year, today.month, today.day);
  final end = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return end.difference(start).inDays;
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _daysText(int days) {
  if (days < 0) return '${days.abs()} days late';
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  return '$days days';
}

String priorityPresetLabel(CountdownPriorityPreset preset) {
  return switch (preset) {
    CountdownPriorityPreset.low => 'Low',
    CountdownPriorityPreset.normal => 'Normal',
    CountdownPriorityPreset.high => 'High',
    CountdownPriorityPreset.critical => 'Critical',
    CountdownPriorityPreset.custom => 'Custom',
  };
}

String priorityDisplay(int priority) {
  return switch (priority) {
    50 => 'Low (50)',
    100 => 'Normal (100)',
    150 => 'High (150)',
    200 => 'Critical (200)',
    _ => 'Custom ($priority)',
  };
}