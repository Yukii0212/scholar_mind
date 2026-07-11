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
    final parents = components
        .where(
          (component) =>
      component.parentId == null,
    )
        .toList();

    return Column(
      children: [
        for (final parent in parents) ...[
          GradingComponentSummaryCard(
            component: parent,
            children: components
                .where(
                  (child) =>
              child.parentId ==
                  parent.id,
            )
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}