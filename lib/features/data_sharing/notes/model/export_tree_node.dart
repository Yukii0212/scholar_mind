import 'export_item.dart';

class ExportTreeNode {
  const ExportTreeNode({
    required this.item,
    required this.children,
  });

  final ExportItem item;

  final List<ExportTreeNode> children;

  bool get hasChildren => children.isNotEmpty;
}