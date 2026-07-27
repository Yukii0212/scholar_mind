import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/export/export_selection.dart';
import 'export_selection_provider.dart';

part 'export_summary_provider.g.dart';

class ExportSummary {
  const ExportSummary({
    required this.totalItems,
  });

  final int totalItems;
}

@riverpod
ExportSummary exportSummary(
    ExportSummaryRef ref,
    ) {
  final ExportSelection selection = ref.watch(
    exportSelectionNotifierProvider,
  );

  return ExportSummary(
    totalItems: selection.totalSelected,
  );
}