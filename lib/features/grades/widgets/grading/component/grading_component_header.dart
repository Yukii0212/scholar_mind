import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/grading/grading_component_draft.dart';

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
            initialValue: component.name,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Component Name',
              isDense: true,
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),

        PopupMenuButton(
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'rename',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Rename'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Delete'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }
}