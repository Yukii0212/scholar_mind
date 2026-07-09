import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/grading/grading_structure_draft_provider.dart';
import 'grading_component_list.dart';

class GradingStructureEditor extends ConsumerWidget {
  const GradingStructureEditor({
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

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () {
            ref
                .read(
              gradingStructureDraftProvider
                  .notifier,
            )
                .addComponent();
          },
          icon: const Icon(Icons.add),
          label: const Text(
            'Add Component',
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: GradingComponentList(
            components: draft.components,
          ),
        ),
      ],
    );
  }
}