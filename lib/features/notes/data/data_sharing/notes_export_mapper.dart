import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';

import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_metadata.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../domain/library_folder.dart';
import '../../domain/note_item.dart';

class NotesExportMapper {
  const NotesExportMapper({
    FirebaseStorage? storage,
  }) : _storage = storage;

  final FirebaseStorage? _storage;

  FirebaseStorage get _storageInstance =>
      _storage ?? FirebaseStorage.instance;

  Future<ShareResource> toResource(
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

  Future<ShareResource> _folder(
      LibraryFolder folder,
      ) async {
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

  Future<ShareResource> _note(
      NoteItem note,
      ) async {
    String? fileBytesBase64;

    if (!note.isInternal && note.storagePath.isNotEmpty) {
      try {
        final bytes = await _storageInstance
            .ref(note.storagePath)
            .getData();

        if (bytes != null) {
          fileBytesBase64 = base64Encode(bytes);
        }
      } catch (_) {
        fileBytesBase64 = null;
      }
    }

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
        'sizeBytes': note.sizeBytes,
        'content': note.content,
        'category': note.category.key,
        'source': note.source,
        'isInternal': note.isInternal,
        'isFavorite': note.isFavorite,
        'fileBytes': fileBytesBase64,
      },
    );
  }
}