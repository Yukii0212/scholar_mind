import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      title: Text(
        item.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: item.subtitle == null
          ? null
          : Text(
        item.subtitle!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
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
          item.module,
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

      case ShareResourceType.countdown:
        return const Icon(Icons.timer_outlined);

      case ShareResourceType.flashcardDeck:
        return const Icon(Icons.style_outlined);

      case ShareResourceType.quizFolder:
        return const Icon(Icons.folder_rounded);

      case ShareResourceType.quiz:
        return const Icon(Icons.quiz_outlined);

      case ShareResourceType.gradeSemester:
        return const Icon(Icons.school_outlined);

      default:
        return const Icon(Icons.dataset_rounded);
    }
  }
}