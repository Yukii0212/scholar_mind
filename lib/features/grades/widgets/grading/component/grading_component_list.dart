import 'package:flutter/material.dart';

import '../../../domain/grading/grading_component_draft.dart';
import 'grading_component_card.dart';

class GradingComponentList
    extends StatelessWidget {
  const GradingComponentList({
    super.key,
    required this.components,
  });

  final List<GradingComponentDraft>
  components;

  @override
  Widget build(BuildContext context) {
    if (components.isEmpty) {
      return const Center(
        child: Text(
          'No grading components yet.',
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < components.length; i++) ...[
          GradingComponentCard(
            key: ValueKey(components[i].id),
            component: components[i],
            isFirst: i == 0,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}