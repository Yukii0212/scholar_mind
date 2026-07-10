import 'package:flutter/material.dart';

import '../../domain/grading/grading_component_draft.dart';
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
        for (final component in components) ...[
          GradingComponentCard(
            component: component,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}