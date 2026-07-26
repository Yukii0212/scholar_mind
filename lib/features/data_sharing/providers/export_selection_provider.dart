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
      Map<ShareResourceType, Set<String>> selections,
      ) {
    final updated = <ShareResourceType, Set<String>>{
      ...state.selectedIds,
    };

    for (final entry in selections.entries) {
      final current = <String>{
        ...?updated[entry.key],
      };

      current.addAll(entry.value);
      updated[entry.key] = current;
    }

    state = state.copyWith(
      selectedIds: updated,
    );
  }

  void unselectAll(
      Map<ShareResourceType, Set<String>> selections,
      ) {
    final updated = <ShareResourceType, Set<String>>{
      ...state.selectedIds,
    };

    for (final entry in selections.entries) {
      final current = <String>{
        ...?updated[entry.key],
      };

      current.removeAll(entry.value);

      if (current.isEmpty) {
        updated.remove(entry.key);
      } else {
        updated[entry.key] = current;
      }
    }

    state = state.copyWith(
      selectedIds: updated,
    );
  }
}