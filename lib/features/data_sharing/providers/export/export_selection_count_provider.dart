import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'export_selection_provider.dart';

part 'export_selection_count_provider.g.dart';

@riverpod
int exportSelectionCount(
    ExportSelectionCountRef ref,
    ) {
  return ref.watch(
    exportSelectionNotifierProvider,
  ).totalSelected;
}