import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/export_item.dart';
import 'export_library_provider.dart';
import '../../providers/export_selection_provider.dart';

part 'export_cart_provider.g.dart';

@riverpod
Future<List<ExportItem>> exportCart(
    ExportCartRef ref,
    ) async {
  final modules = await ref.watch(
    exportLibraryProvider.future,
  );

  final selection = ref.watch(
    exportSelectionNotifierProvider,
  );

  final results = <ExportItem>[];

  for (final module in modules) {

    final itemsById = {
      for (final item in module.items)
        item.id: item,
    };

    bool hasSelectedAncestor(
        ExportItem item,
        ) {
      var parentId = item.parentId;

      while (parentId != null) {
        final parent = itemsById[parentId];

        if (parent == null) {
          break;
        }

        final selected =
            selection.selectedIds[parent.type]
                ?.contains(parent.id) ??
                false;

        if (selected) {
          return true;
        }

        parentId = parent.parentId;
      }

      return false;
    }

    for (final item in module.items) {
      final ids =
      selection.selectedIds[item.type];

      final selected =
          ids?.contains(item.id) ?? false;

      if (!selected) {
        continue;
      }

      if (hasSelectedAncestor(item)) {
        continue;
      }

      int subfolderCount(
          ExportItem root,
          ) {
        var count = 0;

        void visit(String parentId) {
          for (final child in module.items.where(
                (e) => e.parentId == parentId,
          )) {
            if (child.type.name == 'noteFolder') {
              count++;
            }

            visit(child.id);
          }
        }

        visit(root.id);

        return count;
      }

      int noteCount(
          ExportItem root,
          ) {
        var count = 0;

        void visit(String parentId) {
          for (final child in module.items.where(
                (e) => e.parentId == parentId,
          )) {
            if (child.type.name == 'note') {
              count++;
            }

            visit(child.id);
          }
        }

        visit(root.id);

        return count;
      }

      results.add(
        ExportItem(
          id: item.id,
          name: item.name,
          type: item.type,
          module: item.module,
          parentId: item.parentId,
          subtitle: item.subtitle,
          icon: item.icon,
          isSelectable: item.isSelectable,
          childCount: subfolderCount(item),
          noteCount: noteCount(item),
        ),
      );
    }
  }

  return results;
}