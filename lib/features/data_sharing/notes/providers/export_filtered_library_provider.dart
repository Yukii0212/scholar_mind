import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/export_module.dart';
import 'export_library_provider.dart';
import '../../providers/export_search_provider.dart';

part 'export_filtered_library_provider.g.dart';

@riverpod
Future<List<ExportModule>> exportFilteredLibrary(
    ExportFilteredLibraryRef ref,
    ) async {
  final modules = await ref.watch(
    exportLibraryProvider.future,
  );

  final query = ref.watch(
    exportSearchProvider,
  );

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
      items: module.items.where((item) {
        return item.name
            .toLowerCase()
            .contains(lower) ||
            (item.subtitle ?? '')
                .toLowerCase()
                .contains(lower);
      }).toList(),
    ),
  )
      .where((module) => module.items.isNotEmpty)
      .toList();
}