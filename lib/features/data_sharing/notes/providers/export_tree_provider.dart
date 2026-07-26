import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../notes/domain/library_folder.dart';
import '../model/export_item.dart';
import '../model/export_tree_node.dart';
import 'export_library_provider.dart';

part 'export_tree_provider.g.dart';

@riverpod
Future<List<ExportTreeNode>> exportTree(
    ExportTreeRef ref,
    ) async {
  final modules = await ref.watch(
      exportLibraryProvider.future
  );

  final allItems = modules
      .expand((module) => module.items)
      .toList();

  return _buildTree(
    allItems,
    LibraryFolder.rootId,
  );
}

List<ExportTreeNode> _buildTree(
    List<ExportItem> items,
    String? parentId,
    ) {
  final children = items
      .where((e) => e.parentId == parentId)
      .toList();

  return children
      .map(
        (item) => ExportTreeNode(
      item: item,
      children: _buildTree(
        items,
        item.id,
      ),
    ),
  )
      .toList();
}