import '../../domain/models/share/share_resource_type.dart';
import 'export_item.dart';

class ExportTreeNode {
  const ExportTreeNode({
    required this.item,
    required this.children,
  });

  final ExportItem item;

  final List<ExportTreeNode> children;

  bool get isFolder =>
      item.type ==
          ShareResourceType.noteFolder;

  bool get hasChildren =>
      children.isNotEmpty;
}