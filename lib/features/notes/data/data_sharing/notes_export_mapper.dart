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
      CollectedResource resource, {
      required String userId,
      required String shareId,
      }) {
    switch (resource.resourceType) {
      case ShareResourceType.note:
        return _note(
          resource.asType<NoteItem>(),
          userId: userId,
          shareId: shareId,
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
      NoteItem note, {
      required String userId,
      required String shareId,
      }) async {
    // A file's bytes are copied to their own object under this share and
    // only its storage path goes in the payload below — not the bytes
    // themselves. Every note in a recursively-expanded folder used to
    // have its full file embedded (base64) directly in the archive's one
    // JSON payload, so a folder export with several files bundled them
    // all into a single allocation large enough to OOM the app on both
    // the export and the later import side. Copying files one at a time,
    // each to its own object, keeps the archive itself small regardless
    // of how many files a folder pulls in.
    String? sharedFileStoragePath;

    if (!note.isInternal && note.storagePath.isNotEmpty) {
      try {
        final bytes = await _storageInstance
            .ref(note.storagePath)
            .getData();

        if (bytes != null) {
          final safeName = note.displayFileName.replaceAll(
            RegExp(r'[^a-zA-Z0-9._-]'),
            '_',
          );

          final targetPath =
              'users/$userId/shared_exports/$shareId/files/'
              '${note.id}_$safeName';

          await _storageInstance.ref(targetPath).putData(
                bytes,
                SettableMetadata(
                  contentType: _contentTypeFor(note.extension),
                ),
              );

          sharedFileStoragePath = targetPath;
        }
      } catch (_) {
        // File too large, network failure, etc. — export the note's
        // metadata without its file rather than failing the whole export.
        sharedFileStoragePath = null;
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
        'fileStoragePath': sharedFileStoragePath,
      },
    );
  }

  static String _contentTypeFor(String extension) {
    return switch (extension.toLowerCase()) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'txt' => 'text/plain',
      'doc' => 'application/msword',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'ppt' => 'application/vnd.ms-powerpoint',
      'pptx' =>
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      _ => 'application/octet-stream',
    };
  }
}
