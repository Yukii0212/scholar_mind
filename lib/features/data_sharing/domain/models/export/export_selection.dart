import '../share/share_resource_type.dart';

class ExportSelection {
  const ExportSelection({
    required this.selectedIds,
  });

  final Map<ShareResourceType, Set<String>> selectedIds;

  ExportSelection copyWith({
    Map<ShareResourceType, Set<String>>? selectedIds,
  }) {
    return ExportSelection(
      selectedIds: selectedIds ?? this.selectedIds,
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