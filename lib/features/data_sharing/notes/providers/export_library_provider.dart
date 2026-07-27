import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../notes/providers/library_provider.dart';
import '../model/export_item.dart';
import '../model/export_module_group.dart';
import '../../domain/models/export/export_module.dart';
import '../../domain/models/share/share_resource_type.dart';

part 'export_library_provider.g.dart';

@riverpod
Future<List<ExportModuleGroup>> exportLibrary(
    ExportLibraryRef ref,
    ) async {
  final folders = await ref.watch(
    allFoldersProvider.future,
  );

  final notes = await ref.watch(
    allExportableNotesProvider.future,
  );

  final items = <ExportItem>[
    ...folders.map(
          (folder) => ExportItem(
        id: folder.id,
        name: folder.name,
        type: ShareResourceType.noteFolder,
        module: ExportModule.notes,
        parentId: folder.parentId,
      ),
    ),
    ...notes.map(
          (note) => ExportItem(
        id: note.id,
        name: note.name,
            subtitle: note.extension.isEmpty
                ? null
                : note.extension.toUpperCase(),
        type: ShareResourceType.note,
        module: ExportModule.notes,
        parentId: note.folderId,
      ),
    ),
  ];

  ('=== Export Library ===');

  for (final item in items) {
    (
      '${item.type.name} | ${item.name} | id=${item.id} | parent=${item.parentId}',
    );
  }

  return [
    ExportModuleGroup(
      id: 'notes',
      title: 'Notes',
      description: 'Notes, folders and study materials',
      items: items,
    ),
  ];
}