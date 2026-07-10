import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/grading/grading_component_draft.dart';

class GradingSubcomponentRow
    extends ConsumerWidget {
  const GradingSubcomponentRow({
    super.key,
    required this.component,
  });

  final GradingComponentDraft component;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        top: 8,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: component.name,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Subcomponent Name',
              isDense: true,
            ),
          ),

          Row(
            children: [
              SizedBox(
                width: 70,
                child: TextFormField(
                  initialValue:
                  component.weight.toStringAsFixed(0),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    suffixText: '%',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Slider(
                  value: component.weight,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}