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
    this.groupLabel,
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

  /// Non-interactive grouping label used by flat, sectioned export lists
  /// (e.g. a quiz's parent folder name) — has no bearing on selection.
  final String? groupLabel;

  final int childCount;
  final int noteCount;

  final bool isSelectable;

  final ShareResourceType type;

  bool get isFolder => type == ShareResourceType.noteFolder;

  bool get isLeaf => !isFolder;
}