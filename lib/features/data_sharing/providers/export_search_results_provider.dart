import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/export/export_item.dart';
import '../domain/models/export/export_module.dart';
import 'export_library_provider.dart';
import 'export_search_provider.dart';

part 'export_search_results_provider.g.dart';

@riverpod
Future<List<ExportModule>> exportSearchResults(
    ExportSearchResultsRef ref,
    ) async {
  final modules = await ref.watch(
    exportLibraryProvider.future,
  );

  final query = ref.watch(exportSearchProvider).trim();

  if (query.isEmpty) {
    return modules;
  }

  final lower = query.toLowerCase();

  return modules
      .map(
        (module) => ExportModule(
      id: module.id,
      title: module.title,
      description: module.description,
      items: module.items.where(
            (ExportItem item) {
          if (item.name.toLowerCase().contains(lower)) {
            return true;
          }

          if ((item.subtitle ?? '')
              .toLowerCase()
              .contains(lower)) {
            return true;
          }

          return false;
        },
      ).toList(),
    ),
  )
      .where((module) => module.items.isNotEmpty)
      .toList();
}