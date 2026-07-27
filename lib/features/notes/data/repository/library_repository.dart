import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/services/device_id_service.dart';
import '../../domain/library_folder.dart';
import '../../domain/note_category.dart';
import '../../domain/note_item.dart';
import '../../services/file_cache_service.dart';

class LibraryRepository {
  LibraryRepository(this._firestore, this._storage);

  static const maxUploadBytes = 10 * 1024 * 1024;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _folders(String userId) =>
      _firestore.collection('users').doc(userId).collection('folders');

  CollectionReference<Map<String, dynamic>> _notes(String userId) =>
      _firestore.collection('users').doc(userId).collection('notes');

  Stream<List<LibraryFolder>> watchChildFolders(
    String userId,
    String parentId,
  ) {
    return _folders(userId)
        .where('parentId', isEqualTo: parentId)
        .where('isArchived', isEqualTo: false)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final folders = snapshot.docs.map(LibraryFolder.fromDocument).toList();
      folders.sort(_sortFolders);
      return folders;
    });
  }

  Stream<List<LibraryFolder>> watchFavoriteFolders(String userId) {
    return _folders(userId)
        .where('isFavorite', isEqualTo: true)
        .where('isArchived', isEqualTo: false)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final folders = snapshot.docs.map(LibraryFolder.fromDocument).toList();
      folders.sort(_sortFolders);
      return folders;
    });
  }

  Stream<List<NoteItem>> watchFavoriteNotes(
      String userId,
      ) {
    return _notes(userId)
        .where('isFavorite', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final notes =
      snapshot.docs.map(NoteItem.fromDocument).toList();

      notes.sort(
            (a, b) =>
            b.createdAt.compareTo(a.createdAt),
      );

      return notes;
    });
  }

  Stream<List<LibraryFolder>> watchArchivedFolders(String userId) {
    return _folders(userId)
        .where('isArchived', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final folders = snapshot.docs.map(LibraryFolder.fromDocument).toList();
      folders.sort(_sortFolders);
      return folders;
    });
  }

  Stream<List<LibraryFolder>> watchDeletedFolders(String userId) {
    return _folders(userId)
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final folders = snapshot.docs.map(LibraryFolder.fromDocument).toList();
      folders.sort(_sortFolders);
      return folders;
    });
  }

  Stream<List<NoteItem>> watchDeletedNotes(String userId) {
    return _notes(userId)
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final notes = snapshot.docs.map(NoteItem.fromDocument).toList();

      notes.sort(
            (a, b) => (b.deletedAt ?? b.createdAt)
            .compareTo(a.deletedAt ?? a.createdAt),
      );

      return notes;
    });
  }

  Future<void> softDeleteFolder({
    required String userId,
    required String folderId,
  }) async {
    final now = FieldValue.serverTimestamp();

    await _folders(userId).doc(folderId).update({
      'isDeleted': true,
      'deletedAt': now,
      'updatedAt': now,
    });

    await _softDeleteChildren(
      userId: userId,
      parentFolderId: folderId,
    );
  }

  Future<void> _softDeleteChildren({
    required String userId,
    required String parentFolderId,
  }) async {
    final now = FieldValue.serverTimestamp();

    final childFolders = await _folders(userId)
        .where('parentId', isEqualTo: parentFolderId)
        .get();

    for (final folder in childFolders.docs) {
      await folder.reference.update({
        'isDeleted': true,
        'deletedAt': now,
        'updatedAt': now,
      });

      await _softDeleteChildren(
        userId: userId,
        parentFolderId: folder.id,
      );
    }

    final notes = await _notes(userId)
        .where('folderId', isEqualTo: parentFolderId)
        .get();

    for (final note in notes.docs) {
      await note.reference.update({
        'isDeleted': true,
        'deletedAt': now,
        'updatedAt': now,
      });
    }
  }

  Future<void> restoreFolder({
    required String userId,
    required String folderId,
  }) async {
    await _folders(userId).doc(folderId).update({
      'isDeleted': false,
      'deletedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _restoreChildren(
      userId: userId,
      parentFolderId: folderId,
    );
  }

  Future<void> _restoreChildren({
    required String userId,
    required String parentFolderId,
  }) async {
    final childFolders = await _folders(userId)
        .where('parentId', isEqualTo: parentFolderId)
        .get();

    for (final folder in childFolders.docs) {
      await folder.reference.update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _restoreChildren(
        userId: userId,
        parentFolderId: folder.id,
      );
    }

    final notes = await _notes(userId)
        .where('folderId', isEqualTo: parentFolderId)
        .get();

    for (final note in notes.docs) {
      await note.reference.update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> softDeleteNote({
    required String userId,
    required String noteId,
  }) {
    final expiresAt = Timestamp.fromDate(
      DateTime.now().add(
        FileCacheService.cacheDeletionDelay,
      ),
    );

    return _notes(userId).doc(noteId).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'cacheExpiresAt': expiresAt,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> restoreNote({
    required String userId,
    required String noteId,
  }) {
    return _notes(userId).doc(noteId).update({
      'isDeleted': false,
      'deletedAt': null,
      'cacheExpiresAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> restoreAll({
    required String userId,
  }) async {
    final folders = await _folders(userId)
        .where('isDeleted', isEqualTo: true)
        .get();

    for (final folder in folders.docs) {
      final parentId = folder.data()['parentId'] as String;

      final parentDeleted = folders.docs.any(
            (candidate) =>
        candidate.id == parentId &&
            candidate.data()['isDeleted'] == true,
      );

      if (!parentDeleted) {
        await restoreFolder(
          userId: userId,
          folderId: folder.id,
        );
      }
    }

    final notes = await _notes(userId)
        .where('isDeleted', isEqualTo: true)
        .get();

    for (final note in notes.docs) {
      final folderId = note.data()['folderId'] as String;

      final parentDeleted = folders.docs.any(
            (folder) => folder.id == folderId,
      );

      if (!parentDeleted) {
        await restoreNote(
          userId: userId,
          noteId: note.id,
        );
      }
    }
  }

  Future<void> permanentlyDeleteNote({
    required String userId,
    required String noteId,
  }) async {
    final noteDoc = await _notes(userId).doc(noteId).get();

    if (!noteDoc.exists) return;

    final note = NoteItem.fromDocument(noteDoc);

    try {
      await _storage.ref(note.storagePath).delete();
    } catch (_) {
    }

    await noteDoc.reference.delete();
  }

  Future<void> updateInternalNote({
    required String userId,
    required String noteId,
    required String content,
  }) async {
    await _notes(userId).doc(noteId).update({
      'content': content,
    });
  }

  Future<void> renameNote({
    required String userId,
    required String noteId,
    required String name,
  }) async {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError('Note name cannot be empty.');
    }

    await _notes(userId).doc(noteId).update({
      'name': normalizedName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> moveNote({
    required String userId,
    required String noteId,
    required String destinationFolderId,
  }) async {
    final noteDoc =
    await _notes(userId)
        .doc(noteId)
        .get();

    if (!noteDoc.exists) {
      throw ArgumentError('Note not found.');
    }

    final currentFolderId =
    noteDoc.data()?['folderId'];

    if (currentFolderId ==
        destinationFolderId) {
      throw ArgumentError(
        'Note is already in that folder.',
      );
    }

    await _notes(userId).doc(noteId).update({
      'folderId': destinationFolderId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> moveFolder({
    required String userId,
    required String folderId,
    required String destinationFolderId,
  }) async {
    if (folderId == destinationFolderId) {
      final folderDoc =
      await _folders(userId)
          .doc(folderId)
          .get();

      if (!folderDoc.exists) {
        throw ArgumentError('Folder not found.');
      }

      final currentParent =
      folderDoc.data()?['parentId'];

      if (currentParent ==
          destinationFolderId) {
        throw ArgumentError(
          'Folder is already in that location.',
        );
      }throw ArgumentError(
        'A folder cannot be moved into itself.',
      );
    }

    final descendants = await _getDescendantFolderIds(
      userId,
      folderId,
    );

    if (descendants.contains(destinationFolderId)) {
      throw ArgumentError(
        'A folder cannot be moved into its own child folder.',
      );
    }

    await _folders(userId).doc(folderId).update({
      'parentId': destinationFolderId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> copyNote({
    required String userId,
    required String noteId,
    required String destinationFolderId,
  }) async {
    final noteDoc =
    await _notes(userId)
        .doc(noteId)
        .get();

    if (!noteDoc.exists) {
      throw ArgumentError(
        'Note not found.',
      );
    }

    final data = noteDoc.data()!;

    final originalName =
    data['name'] as String;

    await _notes(userId).add({
      'cacheExpiresAt': null,
      ...data,

      'name': '$originalName (Copy)',

      'folderId': destinationFolderId,

      'createdAt':
      FieldValue.serverTimestamp(),

      'updatedAt':
      FieldValue.serverTimestamp(),
    });
  }

  Future<Set<String>> _getDescendantFolderIds(
      String userId,
      String folderId,
      ) async {
    final descendants = <String>{};

    final children = await _folders(userId)
        .where('parentId', isEqualTo: folderId)
        .get();

    for (final child in children.docs) {
      descendants.add(child.id);

      descendants.addAll(
        await _getDescendantFolderIds(
          userId,
          child.id,
        ),
      );
    }

    return descendants;
  }

  Future<void> setNoteFavorite({
    required String userId,
    required String noteId,
    required bool isFavorite,
  }) {
    return _notes(userId).doc(noteId).update({
      'isFavorite': isFavorite,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> permanentlyDeleteFolder({
    required String userId,
    required String folderId,
  }) async {
    await _permanentlyDeleteChildren(
      userId: userId,
      parentFolderId: folderId,
    );

    await _folders(userId).doc(folderId).delete();
  }

  Future<void> permanentlyDeleteAll({
    required String userId,
  }) async {
    final folders = await _folders(userId)
        .where('isDeleted', isEqualTo: true)
        .get();

    for (final folder in folders.docs) {
      final parentId = folder.data()['parentId'] as String;

      final parentDeleted = folders.docs.any(
            (candidate) =>
        candidate.id == parentId &&
            candidate.data()['isDeleted'] == true,
      );

      if (!parentDeleted) {
        await permanentlyDeleteFolder(
          userId: userId,
          folderId: folder.id,
        );
      }
    }

    final notes = await _notes(userId)
        .where('isDeleted', isEqualTo: true)
        .get();

    for (final note in notes.docs) {
      final folderId = note.data()['folderId'] as String;

      final parentDeleted = folders.docs.any(
            (folder) => folder.id == folderId,
      );

      if (!parentDeleted) {
        await permanentlyDeleteNote(
          userId: userId,
          noteId: note.id,
        );
      }
    }
  }

  Future<void> _permanentlyDeleteChildren({
    required String userId,
    required String parentFolderId,
  }) async {
    final childFolders = await _folders(userId)
        .where('parentId', isEqualTo: parentFolderId)
        .get();

    for (final folder in childFolders.docs) {
      await _permanentlyDeleteChildren(
        userId: userId,
        parentFolderId: folder.id,
      );

      await folder.reference.delete();
    }

    final notes = await _notes(userId)
        .where('folderId', isEqualTo: parentFolderId)
        .get();

    for (final noteDoc in notes.docs) {
      final note = NoteItem.fromDocument(noteDoc);

      try {
        await _storage.ref(note.storagePath).delete();
      } catch (_) {
      }

      await noteDoc.reference.delete();
    }
  }

  Stream<List<NoteItem>> watchNotes(String userId, String folderId) {
    return _notes(userId)
        .where('folderId', isEqualTo: folderId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final notes = snapshot.docs.map(NoteItem.fromDocument).toList();
      notes.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
      return notes;
    });
  }

  Stream<NoteItem> watchNote(
      String userId,
      String noteId,
      ) {
    return _notes(userId)
        .doc(noteId)
        .snapshots()
        .map((snapshot) {
      return NoteItem.fromDocument(snapshot);
    });
  }

  Future<NoteItem?> getNote({
    required String userId,
    required String noteId,
  }) async {
    final snapshot =
    await _notes(userId)
        .doc(noteId)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return NoteItem.fromDocument(snapshot);
  }

  Stream<List<NoteItem>> watchAllUploadedNotes(
      String userId,
      ) {
    return _notes(userId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final notes =
      snapshot.docs
          .map(NoteItem.fromDocument)
          .where((note) {
        return !note.isInternal;
      })
          .toList();

      notes.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return notes;
    });
  }

  Stream<List<NoteItem>> watchAllExportableNotes(
      String userId,
      ) {
    return _notes(userId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final notes =
      snapshot.docs.map(NoteItem.fromDocument).toList();

      notes.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return notes;
    });
  }

  Stream<List<LibraryFolder>> watchAllFolders(
      String userId,
      ) {
    return _folders(userId)
        .where('isDeleted', isEqualTo: false)
        .where('isArchived', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final folders =
      snapshot.docs.map(LibraryFolder.fromDocument).toList();

      folders.sort(_sortFolders);

      return folders;
    });
  }

  Future<LibraryFolder?> getFolder({
    required String userId,
    required String folderId,
  }) async {
    final snapshot = await _folders(userId)
        .doc(folderId)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return LibraryFolder.fromDocument(snapshot);
  }

  Future<List<LibraryFolder>> getChildFolders({
    required String userId,
    required String parentFolderId,
  }) async {
    final snapshot = await _folders(userId)
        .where('parentId', isEqualTo: parentFolderId)
        .where('isDeleted', isEqualTo: false)
        .where('isArchived', isEqualTo: false)
        .get();

    final folders =
    snapshot.docs.map(LibraryFolder.fromDocument).toList();

    folders.sort(_sortFolders);

    return folders;
  }

  Future<List<NoteItem>> getNotesInFolder({
    required String userId,
    required String folderId,
  }) async {
    final snapshot = await _notes(userId)
        .where('folderId', isEqualTo: folderId)
        .where('isDeleted', isEqualTo: false)
        .get();

    final notes =
    snapshot.docs.map(NoteItem.fromDocument).toList();

    notes.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return notes;
  }

  Future<void> createFolder({
    required String userId,
    required String parentId,
    required String name,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('Folder name cannot be empty.');
    }

    final now = FieldValue.serverTimestamp();
    await _folders(userId).add({
      'name': normalizedName,
      'parentId': parentId,
      'isFavorite': false,
      'isArchived': false,
      'isDeleted': false,
      'deletedAt': null,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<String> importFolder({
    required String userId,
    required String name,
    required String parentId,
    required bool isFavorite,
  }) async {
    final document = _folders(userId).doc();

    final now = FieldValue.serverTimestamp();

    ('Creating folder: $name');

    await document.set({
      'name': name,
      'parentId': parentId,
      'isFavorite': isFavorite,
      'isArchived': false,
      'isDeleted': false,
      'deletedAt': null,
      'createdAt': now,
      'updatedAt': now,
    });

    ('Created folder ${document.id}');

    return document.id;
  }

  Future<void> importInternalNote({
    required String userId,
    required String folderId,
    required String name,
    required String content,
    required String category,
    required bool isFavorite,
  }) async {
    final now = FieldValue.serverTimestamp();

    await _notes(userId).add({
      'name': name,
      'folderId': folderId,

      'storagePath': '',
      'extension': 'md',
      'sizeBytes': 0,

      'isInternal': true,
      'content': content,

      'category': category,
      'source': 'import',

      'isFavorite': isFavorite,
      'isDeleted': false,
      'deletedAt': null,
      'cacheExpiresAt': null,

      'createdAt': now,
      'updatedAt': now,

      'lockedBy': null,
      'heartbeatAt': null,
      'lockExpiresAt': null,
    });
  }

  Future<void> importUploadedNote({
    required String userId,
    required String folderId,
    required String name,
    required String extension,
    required Uint8List fileBytes,
    required String category,
    required String source,
    required bool isFavorite,
  }) async {
    final noteReference = _notes(userId).doc();
    final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = 'users/$userId/notes/${noteReference.id}/$safeName';
    final storageReference = _storage.ref(storagePath);

    await storageReference.putData(
      fileBytes,
      SettableMetadata(contentType: _contentTypeFor(extension)),
    );

    final now = FieldValue.serverTimestamp();

    try {
      await noteReference.set({
        'name': name,
        'folderId': folderId,

        'storagePath': storagePath,
        'extension': extension,
        'sizeBytes': fileBytes.length,

        'isInternal': false,
        'content': '',

        'category': category,
        'source': source,

        'isFavorite': isFavorite,
        'isDeleted': false,
        'deletedAt': null,
        'cacheExpiresAt': null,

        'createdAt': now,
        'updatedAt': now,

        'lockedBy': null,
        'heartbeatAt': null,
        'lockExpiresAt': null,
      });
    } catch (_) {
      await storageReference.delete();
      rethrow;
    }
  }

  Future<void> renameFolder({
    required String userId,
    required String folderId,
    required String name,
  }) async {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError('Folder name cannot be empty.');
    }

    await _folders(userId).doc(folderId).update({
      'name': normalizedName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createInternalNote({
    required String userId,
    required String folderId,
    required String name,
  }) async {
    final noteName = name.trim();

    if (noteName.isEmpty) {
      throw ArgumentError('Note name cannot be empty.');
    }

    final now = FieldValue.serverTimestamp();

    await _notes(userId).add({
      'name': noteName,
      'folderId': folderId,

      'storagePath': '',
      'extension': 'md',
      'sizeBytes': 0,

      'isInternal': true,
      'content': '# $noteName\n',

      'category': NoteCategory.selfStudyNotes.key,
      'source': 'internal',

      'isFavorite': false,
      'isDeleted': false,
      'deletedAt': null,

      'createdAt': now,
    });
  }

  Future<void> setFolderFavorite({
    required String userId,
    required String folderId,
    required bool isFavorite,
  }) {
    return _folders(userId).doc(folderId).update({
      'isFavorite': isFavorite,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setFolderArchived({
    required String userId,
    required String folderId,
    required bool isArchived,
  }) {
    return _folders(userId).doc(folderId).update({
      'isArchived': isArchived,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadNote({
    required String userId,
    required String folderId,
    required String fileName,
    required String extension,
    required Uint8List bytes,
    required NoteCategory category,
  }) async {
    if (bytes.isEmpty) throw ArgumentError('The selected file is empty.');
    if (bytes.length >= maxUploadBytes) {
      throw ArgumentError('Files must be smaller than 10 MB.');
    }

    final noteReference = _notes(userId).doc();
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = 'users/$userId/notes/${noteReference.id}/$safeName';
    final storageReference = _storage.ref(storagePath);

    await storageReference.putData(
      bytes,
      SettableMetadata(contentType: _contentTypeFor(extension)),
    );

    try {
      final now = FieldValue.serverTimestamp();
      await noteReference.set({
        'name': fileName,
        'folderId': folderId,
        'storagePath': storagePath,
        'extension': extension.toLowerCase(),
        'sizeBytes': bytes.length,
        'category': category.key,
        'source': 'manual',
        'isFavorite': false,
        'isDeleted': false,
        'createdAt': now,
        'updatedAt': now,
        'deletedAt': null,
        'cacheExpiresAt': null,

        'lockedBy': null,
        'heartbeatAt': null,
        'lockExpiresAt': null,
      });
    } catch (_) {
      await storageReference.delete();
      rethrow;
    }

    return storagePath;
  }

  Future<bool> acquireNoteLock({
    required String userId,
    required String noteId,
  }) async {
    final noteReference =
    _notes(userId).doc(noteId);

    final deviceId =
    await DeviceIdService.getDeviceId();

    return _firestore.runTransaction(
          (transaction) async {
        final snapshot =
        await transaction.get(noteReference);

        if (!snapshot.exists) {
          throw ArgumentError(
            'Note not found.',
          );
        }

        final data = snapshot.data()!;

        final now = Timestamp.now();

        final lockExpiresAt =
        data['lockExpiresAt'] as Timestamp?;

        final lockedBy =
        data['lockedBy'] as String?;

        final isExpired =
            lockExpiresAt == null ||
                lockExpiresAt.compareTo(now) <= 0;

        if (!isExpired &&
            lockedBy != deviceId) {
          return false;
        }

        transaction.update(
          noteReference,
          {
            'lockedBy': deviceId,
            'heartbeatAt': now,
            'lockExpiresAt': Timestamp.fromDate(
              DateTime.now().add(
                const Duration(seconds: 15),
              ),
            ),
          },
        );

        return true;
      },
    );
  }

  Future<void> forceAcquireNoteLock({
    required String userId,
    required String noteId,
  }) async {
    final deviceId =
    await DeviceIdService.getDeviceId();

    final now = Timestamp.now();

    await _notes(userId).doc(noteId).update({
      'lockedBy': deviceId,
      'heartbeatAt': now,
      'lockExpiresAt': Timestamp.fromDate(
        DateTime.now().add(
          const Duration(seconds: 15),
        ),
      ),
    });
  }

  Future<void> heartbeatNoteLock({
    required String userId,
    required String noteId,
  }) async {
    final deviceId =
    await DeviceIdService.getDeviceId();

    await _notes(userId).doc(noteId).update({
      'lockedBy': deviceId,
      'heartbeatAt': Timestamp.now(),
      'lockExpiresAt': Timestamp.fromDate(
        DateTime.now().add(
          const Duration(seconds: 5),
        ),
      ),
    });
  }

  static int _sortFolders(LibraryFolder a, LibraryFolder b) {
    if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
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
