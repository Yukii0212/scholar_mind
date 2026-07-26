import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/share/share_resource_type.dart';
import '../../providers/export_selection_provider.dart';
import '../../widgets/dialog/folder_selection_dialog.dart';
import '../model/export_tree_node.dart';
import 'export_item_tile.dart';

class ExportTreeTile extends ConsumerWidget {
  const ExportTreeTile({
    super.key,
    required this.node,
  });

  final ExportTreeNode node;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    if (!node.isFolder) {
      return ExportItemTile(
        item: node.item,
      );
    }

    final selection = ref.watch(
      exportSelectionNotifierProvider,
    );

    final selected =
        selection.selectedIds[node.item.type]
            ?.contains(node.item.id) ??
            false;

    return ExpansionTile(
      initiallyExpanded: false,
      trailing: node.hasChildren
          ? null
          : const SizedBox.shrink(),
      leading: Checkbox(
        value: selected,
        onChanged: (_) async {

          if (selected) {
            final selections =
            <ShareResourceType, Set<String>>{};

            void collect(ExportTreeNode node) {
              selections
                  .putIfAbsent(
                node.item.type,
                    () => <String>{},
              )
                  .add(node.item.id);

              for (final child in node.children) {
                collect(child);
              }
            }

            collect(this.node);

            ref
                .read(
              exportSelectionNotifierProvider
                  .notifier,
            )
                .unselectAll(
              selections,
            );

            return;
          }

          final result =
          await showDialog<
              FolderSelectionOption>(
            context: context,
            builder: (_) =>
                FolderSelectionDialog(
                  folderName: node.item.name,
                ),
          );

          if (result == null) {
            return;
          }

          switch (result) {

            case FolderSelectionOption.folderOnly:

              ref.read(
                exportSelectionNotifierProvider.notifier,
              )
                  .toggle(
                node.item.type,
                node.item.id,
              );

              break;

            case FolderSelectionOption.includeEverything:

              final selections =
              <ShareResourceType, Set<String>>{};

              void collect(ExportTreeNode node) {
                selections
                    .putIfAbsent(
                  node.item.type,
                      () => <String>{},
                )
                    .add(node.item.id);

                for (final child in node.children) {
                  collect(child);
                }
              }

              collect(this.node);

              ref.read(
                exportSelectionNotifierProvider.notifier,
              )
                  .selectAll(
                selections,
              );

              break;
          }
        },
      ),
      title: Text(
        node.item.name,
      ),
      children: [
        for (final child in node.children)
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
            ),
            child: ExportTreeTile(
              node: child,
            ),
          ),
      ],
    );
  }
}