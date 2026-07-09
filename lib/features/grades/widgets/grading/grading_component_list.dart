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

    return ListView.separated(
      itemCount: components.length,
      separatorBuilder: (_, __) =>
      const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return GradingComponentCard(
          component: components[index],
        );
      },
    );
  }
}