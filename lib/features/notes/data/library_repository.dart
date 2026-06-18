import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/library_folder.dart';
import '../domain/note_category.dart';
import '../domain/note_item.dart';

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
        .snapshots()
        .map((snapshot) {
      final folders = snapshot.docs.map(LibraryFolder.fromDocument).toList();
      folders.sort(_sortFolders);
      return folders;
    });
  }

  Stream<List<LibraryFolder>> watchArchivedFolders(String userId) {
    return _folders(userId)
        .where('isArchived', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final folders = snapshot.docs.map(LibraryFolder.fromDocument).toList();
      folders.sort(_sortFolders);
      return folders;
    });
  }

  Stream<List<NoteItem>> watchNotes(String userId, String folderId) {
    return _notes(userId)
        .where('folderId', isEqualTo: folderId)
        .snapshots()
        .map((snapshot) {
      final notes = snapshot.docs.map(NoteItem.fromDocument).toList();
      notes.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
      return notes;
    });
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
      'createdAt': now,
      'updatedAt': now,
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

  Future<void> uploadNote({
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
        'createdAt': now,
        'updatedAt': now,
      });
    } catch (_) {
      await storageReference.delete();
      rethrow;
    }
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
