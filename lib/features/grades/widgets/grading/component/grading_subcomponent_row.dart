import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_design.dart';
import '../../../domain/grading/grading_component_draft.dart';
import '../../../providers/grading/grading_structure_draft_provider.dart';

class GradingSubcomponentRow extends ConsumerStatefulWidget {
  const GradingSubcomponentRow({
    super.key,
    required this.component,
  });

  final GradingComponentDraft component;

  @override
  ConsumerState<GradingSubcomponentRow> createState() =>
      _GradingSubcomponentRowState();
}

class _GradingSubcomponentRowState
    extends ConsumerState<GradingSubcomponentRow> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.component.weight.toStringAsFixed(0),
    );

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant GradingSubcomponentRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    final value = widget.component.weight.toStringAsFixed(0);
    if (_controller.text != value) {
      _controller.text = value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.subdirectory_arrow_right_rounded,
            size: 18,
            color: palette.textMuted,
          ),
          const Gap(8),
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: widget.component.name,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Subcomponent name',
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
              ),
              onChanged: (value) {
                ref
                    .read(gradingStructureDraftProvider.notifier)
                    .renameSubcomponent(
                      componentId: widget.component.id,
                      name: value,
                    );
              },
            ),
          ),
          const Gap(8),
          Expanded(
            flex: 2,
            child: Slider(
              value: widget.component.weight.clamp(0, 100).toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (value) {
                ref
                    .read(gradingStructureDraftProvider.notifier)
                    .updateSubcomponentWeight(
                      componentId: widget.component.id,
                      weight: value,
                    );
              },
            ),
          ),
          SizedBox(
            width: 64,
            child: TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                suffixText: '%',
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
              ),
              onFieldSubmitted: _commitWeight,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              ref
                  .read(gradingStructureDraftProvider.notifier)
                  .removeSubcomponent(widget.component.id);
            },
            icon: const Icon(Icons.close_rounded, size: 18),
            tooltip: 'Remove subcomponent',
          ),
        ],
      ),
    );
  }

  void _commitWeight(String value) {
    final weight = double.tryParse(value) ?? widget.component.weight;

    ref.read(gradingStructureDraftProvider.notifier).updateSubcomponentWeight(
          componentId: widget.component.id,
          weight: weight.clamp(0, 100).toDouble(),
        );
  }
}
