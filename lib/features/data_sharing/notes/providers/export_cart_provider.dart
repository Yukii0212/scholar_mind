import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/export_item.dart';
import 'export_library_provider.dart';
import '../../providers/export_selection_provider.dart';

part 'export_cart_provider.g.dart';

@riverpod
Future<List<ExportItem>> exportCart(
    ExportCartRef ref,
    ) async {
  final modules = await ref.watch(
    exportLibraryProvider.future,
  );

  final selection = ref.watch(
    exportSelectionNotifierProvider,
  );

  final results = <ExportItem>[];

  for (final module in modules) {
    for (final item in module.items) {
      final ids = selection.selectedIds[item.type];

      if (ids?.contains(item.id) ?? false) {
        results.add(item);
      }
    }
  }

  return results;
}