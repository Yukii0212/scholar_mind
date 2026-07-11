import 'package:flutter/material.dart';

import '../../../data/models/grading_component_model.dart';

class GradingComponentSummaryCard
    extends StatelessWidget {
  const GradingComponentSummaryCard({
    super.key,
    required this.component,
    required this.children,
  });

  final GradingComponentModel component;

  final List<GradingComponentModel>
  children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    component.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ),
                Text(
                  '${component.weight.toStringAsFixed(0)}%',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
              ],
            ),

            if (children.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              for (final child
              in children)
                Padding(
                  padding:
                  const EdgeInsets.only(
                    left: 16,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          child.name,
                        ),
                      ),

                      const Text(
                        '—',
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Text(
                        '${child.weight.toStringAsFixed(0)}%',
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .bodyMedium,
                      ),
                    ],
                  ),
                ),
            ] else ...[
              const SizedBox(height: 12),

              Text(
                'No assessments yet',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}