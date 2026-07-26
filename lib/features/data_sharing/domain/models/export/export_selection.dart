import '../share/share_resource_type.dart';

import 'export_module.dart';

class ExportSelection {
  const ExportSelection({
    required this.selectedIds,
    required this.selectedModules,
  });

  final Map<ShareResourceType, Set<String>> selectedIds;

  final Map<String, ExportModule> selectedModules;

  ExportSelection copyWith({
    Map<ShareResourceType, Set<String>>? selectedIds,
    Map<String, ExportModule>? selectedModules,
  }) {
    return ExportSelection(
      selectedIds: selectedIds ?? this.selectedIds,
      selectedModules:
      selectedModules ?? this.selectedModules,
    );
  }

  bool contains(
      ShareResourceType type,
      String id,
      ) {
    return selectedIds[type]?.contains(id) ?? false;
  }

  int get totalSelected {
    var total = 0;

    for (final values in selectedIds.values) {
      total += values.length;
    }

    return total;
  }

  bool get isEmpty => totalSelected == 0;
}