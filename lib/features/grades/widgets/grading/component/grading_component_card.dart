import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/grading/grading_component_draft.dart';
import '../../../domain/grading/grading_component_type.dart';
import '../../../providers/grading/grading_structure_draft_provider.dart';

enum _ComponentAction {
  rename,
  addSubcomponent,
  delete,
}

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

  bool _expanded = true;

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
  Widget build(
      BuildContext context,
      ) {
    return AnimatedSize(
        duration: const Duration(
          milliseconds: 200,
        ),
        curve: Curves.easeInOut,
        child: Card(
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [
        Row(
        children: [
        if (widget.component.children.isNotEmpty)
          IconButton(
          onPressed: () {
        setState(() {
        _expanded = !_expanded;
        });
        },
          icon: Icon(
            _expanded
                ? Icons.expand_more
                : Icons.chevron_right,
          ),
        )
        else
        const SizedBox(width: 48),

    Expanded(
    child: TextFormField(
              initialValue:
              widget.component.name,
              decoration:
              const InputDecoration(
                labelText:
                'Component Name',
              ),
      onChanged: (value) {
        final notifier = ref.read(
          gradingStructureDraftProvider.notifier,
        );

        if (widget.component.type ==
            GradingComponentType.component) {
          notifier.renameComponent(
            componentId: widget.component.id,
            name: value,
          );
        } else {
          notifier.renameSubcomponent(
            componentId: widget.component.id,
            name: value,
          );
        }
      },
    ),
    ),
        ],
        ),

            const SizedBox(height: 16),

    if (_expanded) ...[
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Weight',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        decoration:
                        const InputDecoration(
                          suffixText: '%',
                          border:
                          OutlineInputBorder(),
                          isDense: true,
                        ),
                        onFieldSubmitted: (
                            value,
                            ) {
                          final weight =
                              double.tryParse(
                                value,
                              ) ??
                                  widget.component.weight;

                          final notifier = ref.read(
                            gradingStructureDraftProvider.notifier,
                          );

                          if (widget.component.type ==
                              GradingComponentType.component) {
                            notifier.updateWeight(
                              componentId: widget.component.id,
                              weight: weight.clamp(0, 100),
                            );
                          } else {
                            notifier.updateSubcomponentWeight(
                              componentId: widget.component.id,
                              weight: weight.clamp(0, 100),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Slider(
                        value: widget.component.weight,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label:
                        '${widget.component.weight.toStringAsFixed(0)}%',
                        onChanged: (value) {
                          final notifier = ref.read(
                            gradingStructureDraftProvider.notifier,
                          );

                          if (widget.component.type ==
                              GradingComponentType.component) {
                            notifier.updateWeight(
                              componentId: widget.component.id,
                              weight: value,
                            );
                          } else {
                            notifier.updateSubcomponentWeight(
                              componentId: widget.component.id,
                              weight: value,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<_ComponentAction>(
                onSelected: (action) {
                  switch (action) {
                    case _ComponentAction.rename:
                      break;

                    case _ComponentAction.addSubcomponent:
                      _showAddSubcomponentDialog();
                      break;

                    case _ComponentAction.delete:
                      final notifier = ref.read(
                        gradingStructureDraftProvider.notifier,
                      );

                      if (widget.component.type ==
                          GradingComponentType.component) {
                        notifier.removeComponent(
                          widget.component.id,
                        );
                      } else {
                        notifier.removeSubcomponent(
                          widget.component.id,
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _ComponentAction.rename,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Rename'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  if (widget.component.type ==
                      GradingComponentType.component)
                    const PopupMenuItem(
                      value: _ComponentAction.addSubcomponent,
                      child: ListTile(
                        leading: Icon(Icons.account_tree_outlined),
                        title: Text('Add Subcomponent'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                  const PopupMenuItem(
                    value: _ComponentAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

      if (_expanded)
        ...widget.component.children.map(
              (child) => Padding(
            padding: const EdgeInsets.only(
              left: 32,
              top: 12,
            ),
                child: GradingComponentCard(
                  key: ValueKey(child.id),
                  component: child,
                ),
          ),
        ),
    ],
          ],
        ),
      ),
        ),
    );
  }
}