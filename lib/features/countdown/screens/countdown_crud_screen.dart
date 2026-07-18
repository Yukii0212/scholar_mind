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

class _CountdownCrudScreenState extends ConsumerState<CountdownCrudScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priorityController;
  late final TextEditingController _descriptionController;
  late CountdownType _type;
  late DateTime _dueDate;
  late bool _deadlineExtendable;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _priorityController = TextEditingController(
      text: '${initial?.priority ?? 100}',
    );
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _type = initial?.type ?? CountdownType.finalExamination;
    _dueDate = initial?.dueDate ?? DateTime.now().add(const Duration(days: 7));
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
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: const Text('Save'),
          ),
          const Gap(8),
        ],
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
                      const Gap(16),
                      ScholarPanel(
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: palette.brandEnd),
                            const Gap(12),
                            Expanded(
                              child: Text(
                                _deadlineExtendable
                                    ? 'Extendable overdue countdowns stay active until you complete or edit them.'
                                    : 'Non-extendable overdue countdowns are automatically completed.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: palette.textMuted),
                              ),
                            ),
                          ],
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
                      text: 'Priority $priority',
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
    required this.onChanged,
  });

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
          TextFormField(
            controller: priorityController,
            onChanged: (_) => onChanged(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Priority',
              helperText: 'Higher priority appears first',
              prefixIcon: Icon(Icons.priority_high_rounded),
            ),
            validator: (value) {
              final parsed = int.tryParse((value ?? '').trim());
              if (parsed == null || parsed < 0 || parsed > 999) {
                return 'Enter a number from 0 to 999';
              }
              return null;
            },
          ),
          const Gap(12),
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
              title: const Text('Deadline can be extended'),
              subtitle:
                  const Text('Keep overdue items open for manual action.'),
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
