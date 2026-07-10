import 'package:flutter/material.dart';

import '../../data/models/grading_component_model.dart';

class GradingComponentSummaryCard
    extends StatelessWidget {
  const GradingComponentSummaryCard({
    super.key,
    required this.component,
  });

  final GradingComponentModel component;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          component.name,
        ),
        subtitle: Text(
          'No assessments yet',
        ),
        trailing: Text(
          '${component.weight.toStringAsFixed(0)}%',
          style: Theme.of(context)
              .textTheme
              .titleMedium,
        ),
      ),
    );
  }
}