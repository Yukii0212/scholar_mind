import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/grading/grading_component_draft.dart';
import '../../../providers/grading/grading_structure_draft_provider.dart';

class GradingComponentHeader
    extends ConsumerWidget {
  const GradingComponentHeader({
    super.key,
    required this.component,
  });

  final GradingComponentDraft component;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            onChanged: (value) {
              ref
                  .read(
                gradingStructureDraftProvider.notifier,
              )
                  .renameComponent(
                componentId: component.id,
                name: value,
              );
            },
            initialValue: component.name,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Component Name',
              isDense: true,
              suffixIcon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),
        ),

        PopupMenuButton<String>(
          tooltip: 'More actions',
          onSelected: (value) {
            if (value == 'delete') {
              ref
                  .read(
                gradingStructureDraftProvider.notifier,
              )
                  .removeComponent(
                component.id,
              );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(
                  Icons.delete_outline,
                ),
                title: Text(
                  'Delete',
                ),
                contentPadding:
                EdgeInsets.zero,
              ),
            ),
          ],
        )
      ],
    );
  }
}