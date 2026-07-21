import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_design.dart';
import '../../../domain/grading/grading_component_draft.dart';
import '../../../providers/grading/grading_structure_draft_provider.dart';
import 'grading_component_header.dart';
import 'grading_component_weight_editor.dart';
import 'grading_subcomponent_row.dart';

class GradingComponentCard extends ConsumerStatefulWidget {
  const GradingComponentCard({
    super.key,
    required this.component,
  });

  final GradingComponentDraft component;

  @override
  ConsumerState<GradingComponentCard> createState() =>
      _GradingComponentCardState();
}

class _GradingComponentCardState extends ConsumerState<GradingComponentCard> {
  Future<void> _showAddSubcomponentDialog() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subcomponent'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Subcomponent name',
              prefixIcon: Icon(Icons.add_task_rounded),
            ),
            onSubmitted: (_) {
              Navigator.pop(context, controller.text.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (!mounted || name == null || name.isEmpty) return;

    ref.read(gradingStructureDraftProvider.notifier).addSubcomponent(
          parentId: widget.component.id,
          name: name,
        );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final children = widget.component.children;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ScholarPanel(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GradingComponentHeader(component: widget.component),
            const Gap(14),
            GradingComponentWeightEditor(component: widget.component),
            if (children.isNotEmpty) ...[
              const Gap(16),
              Divider(color: palette.stroke),
              const Gap(10),
              ScholarSectionHeader(
                title: 'Subcomponents',
                subtitle: '${children.length} items inside this component',
              ),
              const Gap(10),
              ...children.map(
                (child) => GradingSubcomponentRow(
                  key: ValueKey(child.id),
                  component: child,
                ),
              ),
              _SubcomponentSummary(component: widget.component),
            ],
            const Gap(8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _showAddSubcomponentDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Subcomponent'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubcomponentSummary extends StatelessWidget {
  const _SubcomponentSummary({
    required this.component,
  });

  final GradingComponentDraft component;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final total = component.children.fold<double>(
      0,
      (sum, child) => sum + child.weight,
    );
    final hasIncompleteWeights = component.children.any(
      (child) => child.weight <= 0 || child.name.trim().isEmpty,
    );
    final valid = total == 100 || total == component.weight;

    final (message, color, icon) = hasIncompleteWeights
        ? (
            'Finish setting up subcomponents to continue.',
            palette.textMuted,
            Icons.info_outline_rounded,
          )
        : valid
            ? (
                total == 100
                    ? 'Using relative weighting inside ${component.name}.'
                    : 'Using final course weighting.',
                palette.success,
                Icons.check_circle_outline_rounded,
              )
            : (
                'Subcomponents must total 100% or ${component.weight.toStringAsFixed(0)}%.',
                Theme.of(context).colorScheme.error,
                Icons.warning_amber_rounded,
              );

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const Gap(8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
