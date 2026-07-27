import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scholar_mind/features/auth/providers/auth_provider.dart';

import '../domain/models/export/export_request.dart';
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

  final user = ref.watch(
    authStateProvider,
  ).value;

  if (user == null) {
    return null;
  }

  return ExportRequest(
    userId: user.uid,
    resourceIds: {
      for (final entry in selection.selectedIds.entries)
        entry.key: entry.value.toList(),
    },
  );
}