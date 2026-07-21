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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.component.weight.toStringAsFixed(0),
    );
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.panelStrong.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.stroke),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const ScholarIconBadge(
                icon: Icons.segment_rounded,
                size: 30,
              ),
              const Gap(10),
              Expanded(
                child: TextFormField(
                  initialValue: widget.component.name,
                  decoration: const InputDecoration(
                    hintText: 'Subcomponent name',
                    isDense: true,
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
              IconButton(
                onPressed: () {
                  ref
                      .read(gradingStructureDraftProvider.notifier)
                      .removeSubcomponent(widget.component.id);
                },
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Remove subcomponent',
              ),
            ],
          ),
          const Gap(10),
          Row(
            children: [
              SizedBox(
                width: 92,
                child: TextFormField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    suffixText: '%',
                    isDense: true,
                  ),
                  onFieldSubmitted: _commitWeight,
                ),
              ),
              const Gap(12),
              Expanded(
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
            ],
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
