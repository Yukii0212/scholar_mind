import 'package:flutter/material.dart';

import '../../../data/models/grading_component_model.dart';
import '../../assessment/assessment_entry_tile.dart';
import '../../dialogs/assessment/assessment_entry_dialog.dart';
import 'grading_weight_information.dart';
import '../../../domain/grading/weight_interpreter.dart';

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
        padding: const EdgeInsets.all(20),
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

              for (var i = 0; i < children.length; i++) ...[
                Builder(
                  builder: (_) {
                    final child = children[i];

                    final weights =
                    WeightInterpreter.interpret(
                      parent: component,
                      siblings: children,
                      child: child,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        bottom: 20,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall,
                          ),

                          const SizedBox(height: 8),

                          GradingWeightInformation(
                            parentName: component.name,
                            componentWeight:
                            weights.componentWeight,
                            overallWeight:
                            weights.overallWeight,
                          ),

                          const SizedBox(height: 16),

                          AssessmentEntryTile(
                            title: 'Actual Score',
                            placeholder:
                            'Tap to enter your actual score',
                            icon: Icons.fact_check_outlined,
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (_) =>
                                    AssessmentEntryDialog(
                                      title: child.name,
                                      componentWeight:
                                      weights.componentWeight,
                                      overallWeight:
                                      weights.overallWeight,
                                      isPrediction: false,
                                    ),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          AssessmentEntryTile(
                            title: 'Expected Score',
                            placeholder:
                            'Tap to enter your expected score',
                            icon: Icons.auto_graph_outlined,
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (_) =>
                                    AssessmentEntryDialog(
                                      title: child.name,
                                      componentWeight:
                                      weights.componentWeight,
                                      overallWeight:
                                      weights.overallWeight,
                                      isPrediction: true,
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                if (i != children.length - 1)
                  const Divider(
                    height: 32,
                  ),
              ],
            ] else ...[
              const SizedBox(height: 12),

              Text(
                'No subcomponents yet.\n'
                    'Scores can be entered once '
                    'assessments are created.',
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