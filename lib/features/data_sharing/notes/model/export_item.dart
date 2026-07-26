import '../../domain/models/export/export_module.dart';
import '../../domain/models/share/share_resource_type.dart';

class ExportItem {
  const ExportItem({
    required this.id,
    required this.name,
    required this.type,
    required this.module,
    this.parentId,
    this.subtitle,
    this.icon,
    this.childCount = 0,
    this.noteCount = 0,
    this.isSelectable = true,
  });

  final String id;
  final String name;
  final ExportModule module;
  final String? parentId;
  final String? subtitle;
  final String? icon;

  final int childCount;
  final int noteCount;

  final bool isSelectable;

  final ShareResourceType type;

  bool get isFolder => type == ShareResourceType.noteFolder;

  bool get isLeaf => !isFolder;
}