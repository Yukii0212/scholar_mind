import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/export/export_module.dart';
import '../domain/models/export/export_selection.dart';
import '../domain/models/share/share_resource_type.dart';

part 'export_selection_provider.g.dart';

@riverpod
class ExportSelectionNotifier extends _$ExportSelectionNotifier {
  @override
  ExportSelection build() {
    return const ExportSelection(
      selectedIds: {},
      selectedModules: {},
    );
  }

  void toggle(
      ShareResourceType type,
      String id,
      ExportModule module,
      ) {
    final updated = <ShareResourceType, Set<String>>{
      ...state.selectedIds,
    };

    final modules = <String, ExportModule>{
      ...state.selectedModules,
    };

    final current = <String>{
      ...?updated[type],
    };

    if (current.contains(id)) {
      current.remove(id);
      modules.remove(id);
    } else {
      current.add(id);
      modules[id] = module;
    }

    updated[type] = current;

    state = state.copyWith(
      selectedIds: updated,
      selectedModules: modules,
    );

    ('=== Selection Updated ===');

    for (final entry in state.selectedIds.entries) {
      (
        '${entry.key.name}: ${entry.value.toList()}',
      );
    }
  }

  void clear() {
    state = const ExportSelection(
      selectedIds: {},
      selectedModules: {},
    );
  }

  void selectAll(
      Map<ShareResourceType, Set<String>> selections,
      ExportModule module,
      ) {
    final updated = <ShareResourceType, Set<String>>{
      ...state.selectedIds,
    };

    final modules = <String, ExportModule>{
      ...state.selectedModules,
    };

    for (final entry in selections.entries) {
      final current = <String>{
        ...?updated[entry.key],
      };

      current.addAll(entry.value);

      for (final id in entry.value) {
        modules[id] = module;
      }

      updated[entry.key] = current;
    }

    state = state.copyWith(
      selectedIds: updated,
      selectedModules: modules,
    );
  }

  void unselectAll(
      Map<ShareResourceType, Set<String>> selections,
      ) {
    final updated = <ShareResourceType, Set<String>>{
      ...state.selectedIds,
    };

    final modules = <String, ExportModule>{
      ...state.selectedModules,
    };

    for (final entry in selections.entries) {
      final current = <String>{
        ...?updated[entry.key],
      };

      current.removeAll(entry.value);

      for (final id in entry.value) {
        modules.remove(id);
      }

      if (current.isEmpty) {
        updated.remove(entry.key);
      } else {
        updated[entry.key] = current;
      }
    }

    state = state.copyWith(
      selectedIds: updated,
      selectedModules: modules,
    );
  }
}