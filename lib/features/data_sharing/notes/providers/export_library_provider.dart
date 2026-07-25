import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../notes/providers/library_provider.dart';
import '../model/export_item.dart';
import '../model/export_module.dart';
import '../../domain/models/share/share_resource_type.dart';

part 'export_library_provider.g.dart';

@riverpod
Future<List<ExportModule>> exportLibrary(
    ExportLibraryRef ref,
    ) async {
  final folders = await ref.watch(
    allFoldersProvider.future,
  );

  final notes = await ref.watch(
    allUploadedNotesProvider.future,
  );

  final items = <ExportItem>[
    ...folders.map(
          (folder) => ExportItem(
        id: folder.id,
        name: folder.name,
        type: ShareResourceType.noteFolder,
        module: 'Notes',
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
        module: 'Notes',
        parentId: note.folderId,
      ),
    ),
  ];

  return [
    ExportModule(
      id: 'notes',
      title: 'Notes',
      description: 'Notes, folders and study materials',
      items: items,
    ),
  ];
}