import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../domain/models/export/export_module.dart';
import '../model/export_item.dart';
import '../../domain/models/share/share_resource_type.dart';
import '../../providers/export_selection_provider.dart';

class ExportItemTile extends ConsumerWidget {
  const ExportItemTile({
    super.key,
    required this.item,
    this.onTap,
  });

  final ExportItem item;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(
      exportSelectionNotifierProvider,
    );

    final selected = selection.contains(
      item.type,
      item.id,
    );

    return CheckboxListTile(
      value: selected,
      controlAffinity:
      ListTileControlAffinity.leading,
      title: Text(item.name),
      subtitle: item.subtitle == null
          ? null
          : Text(item.subtitle!),
      secondary: _buildIcon(),
      onChanged: (_) {
        ref
            .read(
          exportSelectionNotifierProvider
              .notifier,
        )
            .toggle(
          item.type,
          item.id,
          ExportModule.notes,
        );

        onTap?.call();
      },
    );
  }

  Widget _buildIcon() {
    switch (item.type) {
      case ShareResourceType.noteFolder:
        return const Icon(Icons.folder_rounded);

      case ShareResourceType.note:
        return const Icon(Icons.description_rounded);

      default:
        return const Icon(Icons.dataset_rounded);
    }
  }
}