

import '../../domain/models/share/share_resource_type.dart';

class ExportCartItem {
  const ExportCartItem({
    required this.id,
    required this.name,
    required this.type,
    required this.module,
    this.subtitle,
    this.childCount = 0,
    this.noteCount = 0,
  });

  final String id;

  final String name;

  final ShareResourceType type;

  final String module;

  final String? subtitle;

  final int childCount;

  final int noteCount;

  bool get isFolder =>
      type == ShareResourceType.noteFolder;
}