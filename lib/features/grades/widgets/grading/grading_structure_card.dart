import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/grading/grading_structure_draft_provider.dart';
import '../dialogs/grading/grading_component_dialog.dart';
import 'grading_component_list.dart';

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

            const SizedBox(height: 24),

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
              SizedBox(
                height: 400,
                child: GradingComponentList(
                  components:
                  draft.components,
                ),
              ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
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
          ],
        ),
      ),
    );
  }
}