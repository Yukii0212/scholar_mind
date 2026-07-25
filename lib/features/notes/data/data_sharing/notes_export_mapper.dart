import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_metadata.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../domain/library_folder.dart';
import '../../domain/note_item.dart';

class NotesExportMapper {
  const NotesExportMapper();

  ShareResource toResource(
      CollectedResource resource,
      ) {
    switch (resource.resourceType) {
      case ShareResourceType.note:
        return _note(
          resource.asType<NoteItem>(),
        );

      case ShareResourceType.noteFolder:
        return _folder(
          resource.asType<LibraryFolder>(),
        );

      default:
        throw UnsupportedError(
          'Unsupported Notes resource: '
              '${resource.resourceType}',
        );
    }
  }

  ShareResource _folder(
      LibraryFolder folder,
      ) {
    return ShareResource(
      resourceType: ShareResourceType.noteFolder,
      resourceVersion: 1,
      resourceId: folder.id,
      metadata: ShareResourceMetadata(
        displayName: folder.name,
        createdAt: folder.createdAt,
        updatedAt: folder.updatedAt,
      ),
      payload: {
        'parentId': folder.parentId,
        'isFavorite': folder.isFavorite,
      },
    );
  }

  ShareResource _note(
      NoteItem note,
      ) {
    return ShareResource(
      resourceType: ShareResourceType.note,
      resourceVersion: 1,
      resourceId: note.id,
      metadata: ShareResourceMetadata(
        displayName: note.name,
        createdAt: note.createdAt,
        updatedAt: note.createdAt,
      ),
      payload: {
        'folderId': note.folderId,
        'extension': note.extension,
        'storagePath': note.storagePath,
        'sizeBytes': note.sizeBytes,
        'content': note.content,
        'category': note.category.key,
        'source': note.source,
        'isInternal': note.isInternal,
        'isFavorite': note.isFavorite,
      },
    );
  }
}