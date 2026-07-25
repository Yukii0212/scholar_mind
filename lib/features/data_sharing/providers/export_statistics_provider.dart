import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../domain/models/export/export_statistics.dart';
import '../domain/models/share/share_resource_type.dart';
import 'export_library_provider.dart';
import 'export_selection_provider.dart';

part 'export_statistics_provider.g.dart';

@riverpod
Future<ExportStatistics> exportStatistics(
    ExportStatisticsRef ref,
    ) async {
  final modules = await ref.watch(
    exportLibraryProvider.future,
  );

  final selection = ref.watch(
    exportSelectionNotifierProvider,
  );

  final folders = selection
      .selectedIds[
  ShareResourceType.noteFolder]
      ?.length ??
      0;

  final notes = selection
      .selectedIds[ShareResourceType.note]
      ?.length ??
      0;

  return ExportStatistics(
    selectedItems: notes,
    selectedFolders: folders,
    totalModules: modules.length,
  );
}