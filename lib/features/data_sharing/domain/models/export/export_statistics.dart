class ExportStatistics {
  const ExportStatistics({
    required this.selectedItems,
    required this.selectedFolders,
    required this.totalModules,
  });

  final int selectedItems;
  final int selectedFolders;
  final int totalModules;

  bool get hasSelection =>
      selectedItems > 0 || selectedFolders > 0;
}