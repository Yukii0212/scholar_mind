import 'package:flutter/material.dart';

import '../model/export_tree_node.dart';
import 'export_item_tile.dart';

class ExportTreeTile extends StatelessWidget {
  const ExportTreeTile({
    super.key,
    required this.node,
  });

  final ExportTreeNode node;

  @override
  Widget build(BuildContext context) {
    if (!node.hasChildren) {
      return ExportItemTile(
        item: node.item,
      );
    }

    return ExpansionTile(
      leading: const Icon(
        Icons.folder_rounded,
      ),
      title: Text(
        node.item.name,
      ),
      children: [
        for (final child in node.children)
          Padding(
            padding:
            const EdgeInsets.only(
              left: 20,
            ),
            child: ExportTreeTile(
              node: child,
            ),
          ),
      ],
    );
  }
}