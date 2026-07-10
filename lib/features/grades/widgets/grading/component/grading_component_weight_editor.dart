import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/grading/grading_component_draft.dart';
import '../../../providers/grading/grading_structure_draft_provider.dart';
import 'grading_component_weight_editor.dart';

class GradingComponentWeightEditor
    extends ConsumerStatefulWidget {

  const GradingComponentWeightEditor({
    super.key,
    required this.component,
  });

  final GradingComponentDraft component;

  @override
  ConsumerState<GradingComponentWeightEditor>
  createState() =>
      _GradingComponentWeightEditorState();
}

class _GradingComponentWeightEditorState
    extends ConsumerState<
        GradingComponentWeightEditor> {

  late final TextEditingController
  _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text:
      widget.component.weight.toStringAsFixed(0),
    );
  }

  @override
  void didUpdateWidget(
      covariant GradingComponentWeightEditor
      oldWidget) {
    super.didUpdateWidget(oldWidget);

    final value =
    widget.component.weight.toStringAsFixed(0);

    if (_controller.text != value) {
      _controller.text = value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                controller: _controller,
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
                          widget.component.weight;

                  ref
                      .read(
                    gradingStructureDraftProvider.notifier,
                  )
                      .updateWeight(
                    componentId: widget.component.id,
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
                value: widget.component.weight,
                min: 0,
                max: 100,
                divisions: 100,
                label:
                '${widget.component.weight.toStringAsFixed(0)}%',
                onChanged: (value) {
                  ref
                      .read(
                    gradingStructureDraftProvider.notifier,
                  )
                      .updateWeight(
                    componentId: widget.component.id,
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