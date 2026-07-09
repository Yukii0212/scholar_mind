import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/grading/grading_component_draft.dart';
import '../../providers/grading/grading_structure_draft_provider.dart';

class GradingComponentCard
    extends ConsumerWidget {
  const GradingComponentCard({
    super.key,
    required this.component,
  });

  final GradingComponentDraft
  component;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              initialValue:
              component.name,
              decoration:
              const InputDecoration(
                labelText:
                'Component Name',
              ),
              onChanged: (value) {
                ref
                    .read(
                  gradingStructureDraftProvider
                      .notifier,
                )
                    .renameComponent(
                  componentId:
                  component.id,
                  name: value,
                );
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Slider(
                    value:
                    component.weight,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label:
                    '${component.weight.toStringAsFixed(0)}%',
                    onChanged:
                        (value) {
                      ref
                          .read(
                        gradingStructureDraftProvider
                            .notifier,
                      )
                          .updateWeight(
                        componentId:
                        component
                            .id,
                        weight:
                        value,
                      );
                    },
                  ),
                ),

                SizedBox(
                  width: 48,
                  child: Text(
                    '${component.weight.toStringAsFixed(0)}%',
                    textAlign:
                    TextAlign.center,
                  ),
                ),
              ],
            ),

            Align(
              alignment:
              Alignment.centerRight,
              child: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                ),
                onPressed: () {
                  ref
                      .read(
                    gradingStructureDraftProvider
                        .notifier,
                  )
                      .removeComponent(
                    component.id,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}