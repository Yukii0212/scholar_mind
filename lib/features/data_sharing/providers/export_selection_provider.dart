import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/export/export_selection.dart';
import '../domain/models/share/share_resource_type.dart';

part 'export_selection_provider.g.dart';

@riverpod
class ExportSelectionNotifier extends _$ExportSelectionNotifier {
  @override
  ExportSelection build() {
    return const ExportSelection(
      selectedIds: {},
    );
  }

  void toggle(
      ShareResourceType type,
      String id,
      ) {
    final updated = <ShareResourceType, Set<String>>{
      ...state.selectedIds,
    };

    final current = <String>{
      ...?updated[type],
    };

    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }

    updated[type] = current;

    state = state.copyWith(
      selectedIds: updated,
    );
  }

  void clear() {
    state = const ExportSelection(
      selectedIds: {},
    );
  }

  void selectAll(
      ShareResourceType type,
      Iterable<String> ids,
      ) {
    final updated = <ShareResourceType, Set<String>>{
      ...state.selectedIds,
    };

    final current = <String>{
      ...?updated[type],
    };

    current.addAll(ids);

    updated[type] = current;

    state = state.copyWith(
      selectedIds: updated,
    );
  }

  void unselectAll(
      ShareResourceType type,
      Iterable<String> ids,
      ) {
    final updated = <ShareResourceType, Set<String>>{
      ...state.selectedIds,
    };

    final current = <String>{
      ...?updated[type],
    };

    current.removeAll(ids);

    if (current.isEmpty) {
      updated.remove(type);
    } else {
      updated[type] = current;
    }

    state = state.copyWith(
      selectedIds: updated,
    );
  }
}