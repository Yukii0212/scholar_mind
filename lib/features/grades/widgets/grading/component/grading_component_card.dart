import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/grading/grading_component_draft.dart';
import '../../../providers/grading/grading_structure_draft_provider.dart';
import 'grading_component_header.dart';
import 'grading_component_weight_editor.dart';
import 'grading_subcomponent_row.dart';

class GradingComponentCard
    extends ConsumerStatefulWidget {
  const GradingComponentCard({
    super.key,
    required this.component,
  });

  final GradingComponentDraft
  component;

  @override
  ConsumerState<GradingComponentCard>
  createState() =>
      _GradingComponentCardState();
}

class _GradingComponentCardState
    extends ConsumerState<
        GradingComponentCard> {

  late final TextEditingController
  _weightController;

  Future<void> _showAddSubcomponentDialog() async {
    final controller =
    TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Add Subcomponent',
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration:
            const InputDecoration(
              labelText:
              'Subcomponent Name',
            ),
            onSubmitted: (_) {
              Navigator.pop(
                context,
                controller.text.trim(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },
              child: const Text(
                'Add',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted ||
        name == null ||
        name.isEmpty) {
      return;
    }

    ref
        .read(
      gradingStructureDraftProvider
          .notifier,
    )
        .addSubcomponent(
      parentId: widget.component.id,
      name: name,
    );
  }

  @override
  void initState() {
    super.initState();

    _weightController =
        TextEditingController(
          text: widget.component.weight
              .toStringAsFixed(0),
        );
  }

  @override
  void didUpdateWidget(
      covariant GradingComponentCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final value = widget.component.weight
        .toStringAsFixed(0);

    if (_weightController.text != value) {
      _weightController.text = value;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [

                GradingComponentHeader(
                  component: widget.component,
                ),

                Positioned(
                  right: 0,
                  child: Tooltip(
                    message:
                    'Click the component name to rename it.',
                    child: Icon(
                      Icons.edit,
                      size: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            GradingComponentWeightEditor(
              component: widget.component,
            ),

            if (widget.component.children.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),

              Text(
                'Subcomponents',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall,
              ),

              const SizedBox(height: 12),

              ...widget.component.children.map(
                    (child) => GradingSubcomponentRow(
                  key: ValueKey(child.id),
                  component: child,
                ),
              ),
            ],

            const SizedBox(height: 16),

            if (widget.component.children.isNotEmpty) ...[
              Builder(
                builder: (_) {
                  final total = widget.component.children.fold<double>(
                    0,
                        (sum, child) => sum + child.weight,
                  );

                  final parentWeight = widget.component.weight;

                  final hasIncompleteWeights =
                  widget.component.children.any(
                        (child) =>
                    child.weight <= 0 ||
                        child.name.trim().isEmpty,
                  );

                  final valid =
                      total == 100 ||
                          total == parentWeight;

                  String message;

                  Color color;

                  if (hasIncompleteWeights) {
                    message =
                    'Finish setting up your subcomponents to continue.';
                    color = Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant;
                  } else if (valid) {
                    message = total == 100
                        ? '✓ Using "${widget.component.name}" relative weighting.'
                        : '✓ Using final course weighting.';

                    color = Colors.green;
                  } else {
                    message =
                    'Subcomponents must total either '
                        '100% or '
                        '${parentWeight.toStringAsFixed(0)}%.';

                    color = Theme.of(context)
                        .colorScheme
                        .error;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 12,
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: color,
                      ),
                    ),
                  );
                },
              ),
            ],

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _showAddSubcomponentDialog,
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'Add Subcomponent',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}