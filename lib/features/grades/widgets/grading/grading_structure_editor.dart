import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/grading/grading_structure_draft_provider.dart';
import '../dialogs/grading/grading_component_dialog.dart';
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