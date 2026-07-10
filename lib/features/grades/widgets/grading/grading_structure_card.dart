import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/grading/grading_structure_draft_provider.dart';
import '../dialogs/grading/grading_component_dialog.dart';
import 'component/grading_component_list.dart';

class GradingStructureCard extends ConsumerWidget {
  const GradingStructureCard({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final draft = ref.watch(
      gradingStructureDraftProvider,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            Text(
              'Grading Structure',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),

            const SizedBox(height: 8),

            Text(
              'Create the grading components used to calculate the final grade for this course.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            if (draft.components.isEmpty)
              Container(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                        .dividerColor,
                  ),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_tree_outlined,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'No components yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Add your first grading component to begin building this grading structure.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              GradingComponentList(
                components: draft.components,
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final name =
                  await showDialog<String>(
                    context: context,
                    builder: (_) =>
                    const GradingComponentDialog(),
                  );

                  if (name == null) {
                    return;
                  }

                  ref
                      .read(
                    gradingStructureDraftProvider
                        .notifier,
                  )
                      .addComponent(
                    name: name,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Component',
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Advanced',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 0,
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            contentPadding:
                            EdgeInsets.zero,
                            title: const Text(
                              'Auto Balance',
                            ),
                            value: draft.autoBalance,
                            onChanged: (value) {
                              ref
                                  .read(
                                gradingStructureDraftProvider
                                    .notifier,
                              )
                                  .setAutoBalance(value);
                            },
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                              const _AutoBalanceInfoDialog(),
                            );
                          },
                        ),
                      ],
                    ),

                    if (!draft.autoBalance) ...[
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              ref
                                  .read(
                                gradingStructureDraftProvider
                                    .notifier,
                              )
                                  .balanceDistribution();
                            },
                            icon: const Icon(
                              Icons.balance,
                            ),
                            label: const Text(
                              'Rebalance',
                            ),
                          ),

                          const SizedBox(height: 12),

                          OutlinedButton.icon(
                            onPressed: () {
                              ref
                                  .read(
                                gradingStructureDraftProvider
                                    .notifier,
                              )
                                  .resetDistribution();
                            },
                            icon: const Icon(
                              Icons.refresh,
                            ),
                            label: const Text(
                              'Reset',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
                ],
              ),
      ),
    );
  }
}

class _AutoBalanceInfoDialog
    extends StatelessWidget {
  const _AutoBalanceInfoDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Auto Balance',
      ),
      content: const Text(
        'Auto Balance automatically redistributes the remaining grading weights whenever you edit a component so the total always equals 100%.\n\n'

            'If Auto Balance is disabled:\n\n'

            '• The "Rebalance" button will redistribute the remaining weights while keeping the most recently edited component unchanged.\n\n'

            '• The "Reset" button will evenly redistribute the weight across all grading components.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Close',
          ),
        ),
      ],
    );
  }
}