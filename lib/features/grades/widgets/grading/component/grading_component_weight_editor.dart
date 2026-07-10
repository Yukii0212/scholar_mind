import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/grading/grading_component_draft.dart';
import '../../../providers/grading/grading_structure_draft_provider.dart';

class GradingComponentWeightEditor
    extends ConsumerWidget {
  const GradingComponentWeightEditor({
    super.key,
    required this.component,
  });

  final GradingComponentDraft component;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight',
          style: Theme.of(context).textTheme.labelLarge,
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: component.weight.toStringAsFixed(0),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  suffixText: '%',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onFieldSubmitted: (value) {
                  final weight =
                      double.tryParse(value) ??
                          component.weight;

                  ref
                      .read(
                    gradingStructureDraftProvider.notifier,
                  )
                      .updateWeight(
                    componentId: component.id,
                    weight: weight.clamp(
                      0,
                      100,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Slider(
                value: component.weight,
                min: 0,
                max: 100,
                divisions: 100,
                label:
                '${component.weight.toStringAsFixed(0)}%',
                onChanged: (value) {
                  ref
                      .read(
                    gradingStructureDraftProvider.notifier,
                  )
                      .updateWeight(
                    componentId: component.id,
                    weight: value,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}