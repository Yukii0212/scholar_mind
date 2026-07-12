import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/grading_component_model.dart';
import '../../../domain/assessment/assessment_type.dart';
import '../../../providers/assessment/assessment_provider.dart';
import '../../assessment/assessment_entry_tile.dart';
import '../../dialogs/assessment/assessment_entry_dialog.dart';
import 'grading_weight_information.dart';
import '../../../domain/grading/weight_interpreter.dart';

class GradingComponentSummaryCard
    extends ConsumerWidget {
  const GradingComponentSummaryCard({
    super.key,
    required this.component,
    required this.children,
  });

  final GradingComponentModel component;

  final List<GradingComponentModel>
  children;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final assessmentTargets =
    children.isEmpty
        ? <GradingComponentModel>[
      component,
    ]
        : children;
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

            if (assessmentTargets.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              for (var i = 0; i < assessmentTargets.length; i++) ...[
                Builder(
                  builder: (_) {
                    final child = assessmentTargets[i];

                    final assessmentEntries =
                    ref.watch(
                      assessmentEntriesProvider(
                        component.courseId,
                      ),
                    );

                    final actualEntry =
                    assessmentEntries.when(
                      data: (entries) {
                        final matches = entries.where(
                              (entry) =>
                          entry.componentId ==
                              child.id &&
                              entry.type ==
                                  AssessmentType.actual,
                        );

                        return matches.isEmpty
                            ? null
                            : matches.first;
                      },
                      loading: () => null,
                      error: (_, __) => null,
                    );

                    final expectedEntry =
                    assessmentEntries.when(
                      data: (entries) {
                        final matches = entries.where(
                              (entry) =>
                          entry.componentId ==
                              child.id &&
                              entry.type ==
                                  AssessmentType.expected,
                        );

                        return matches.isEmpty
                            ? null
                            : matches.first;
                      },
                      loading: () => null,
                      error: (_, __) => null,
                    );
                    final componentWeight =
                    children.isEmpty
                        ? component.weight
                        : WeightInterpreter
                        .interpret(
                      parent: component,
                      siblings: children,
                      child: child,
                    )
                        .componentWeight;

                    final overallWeight =
                    children.isEmpty
                        ? component.weight
                        : WeightInterpreter
                        .interpret(
                      parent: component,
                      siblings: children,
                      child: child,
                    )
                        .overallWeight;

                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        bottom: 20,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          if (children.isNotEmpty) ...[
                            Text(
                              child.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),

                            const SizedBox(height: 8),
                          ],

                          GradingWeightInformation(
                            parentName: component.name,
                            componentWeight:
                            componentWeight,
                            overallWeight:
                            overallWeight,
                          ),

                          const SizedBox(height: 12),

                          AssessmentEntryTile(
                            title: 'Actual Score',
                            placeholder:
                            'Tap to enter your actual score',
                            savedScore:
                            actualEntry == null
                                ? null
                                : '${actualEntry.score.toStringAsFixed(0)} / '
                                '${actualEntry.denominator.toStringAsFixed(0)}',
                            savedPercentage:
                            actualEntry == null
                                ? null
                                : '${actualEntry.percentage.toStringAsFixed(0)}%',
                            icon:
                            Icons.fact_check_outlined,
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (_) =>
                                    AssessmentEntryDialog(
                                      title: child.name,
                                      courseId:
                                      component.courseId,
                                      componentId:
                                      child.id,
                                      componentWeight:
                                      componentWeight,

                                      overallWeight:
                                      overallWeight,
                                      isPrediction: false,
                                    ),
                              );
                            },
                          ),

                    if (actualEntry == null ||
                    expectedEntry != null) ...[

                    const SizedBox(height: 12),

                    AssessmentEntryTile(
                    title: 'Expected Score',
                    placeholder:
                    'Tap to enter your expected score',
                            savedScore:
                            expectedEntry == null
                                ? null
                                : '${expectedEntry.score.toStringAsFixed(0)} / '
                                '${expectedEntry.denominator.toStringAsFixed(0)}',
                            savedPercentage:
                            expectedEntry == null
                                ? null
                                : 'Equivalent to '
                                '${expectedEntry.percentage.toStringAsFixed(0)}%',
                            icon:
                            Icons.auto_graph_outlined,
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (_) =>
                                    AssessmentEntryDialog(
                                      title: child.name,
                                      courseId:
                                      component.courseId,
                                      componentId:
                                      child.id,
                                      componentWeight:
                                      componentWeight,

                                      overallWeight:
                                      overallWeight,
                                      isPrediction: true,
                                    ),
                              );
                            },
                    ),
                    ],
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
            ],
          ],
        ),
      ),
    );
  }
}