import 'package:flutter/material.dart';

import '../../../data/models/grading_component_model.dart';
import 'grading_component_summary_card.dart';

class GradingComponentSummaryList
    extends StatelessWidget {
  const GradingComponentSummaryList({
    super.key,
    required this.components,
  });

  final List<GradingComponentModel>
  components;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final component
        in components) ...[
          GradingComponentSummaryCard(
            component: component,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}