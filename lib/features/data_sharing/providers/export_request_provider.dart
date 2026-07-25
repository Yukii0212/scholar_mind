import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scholar_mind/features/data_sharing/providers/share_method_provider.dart';


import '../domain/models/export/export_request.dart';
import '../domain/models/share/share_method.dart';
import 'export_selection_provider.dart';

part 'export_request_provider.g.dart';

@riverpod
ExportRequest? exportRequest(
    ExportRequestRef ref,
    ) {
  final selection = ref.watch(
    exportSelectionNotifierProvider,
  );

  if (selection.isEmpty) {
    return null;
  }

  final method = ref.watch(
    shareMethodNotifierProvider,
  );

  return ExportRequest(
    userId: '',
    method: method,
    resourceIds: {
      for (final entry
      in selection.selectedIds.entries)
        entry.key: entry.value.toList(),
    },
  );
}