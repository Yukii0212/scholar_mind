import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/library_repository.dart';
import '../domain/library_folder.dart';
import '../domain/note_category.dart';
import '../domain/note_item.dart';

part 'library_provider.g.dart';

@Riverpod(keepAlive: true)
LibraryRepository libraryRepository(LibraryRepositoryRef ref) {
  return LibraryRepository(
      FirebaseFirestore.instance, FirebaseStorage.instance);
}

@riverpod
Stream<List<LibraryFolder>> childFolders(
  ChildFoldersRef ref,
  String parentId,
) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return const Stream.empty();

  return ref
      .watch(libraryRepositoryProvider)
      .watchChildFolders(userId, parentId);
}

@riverpod
Stream<List<LibraryFolder>> favoriteFolders(FavoriteFoldersRef ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return const Stream.empty();

  return ref.watch(libraryRepositoryProvider).watchFavoriteFolders(userId);
}

@riverpod
Stream<List<NoteItem>> favoriteNotes(
    FavoriteNotesRef ref,
    ) {
  final userId =
      ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) {
    return const Stream.empty();
  }

  return ref
      .watch(libraryRepositoryProvider)
      .watchFavoriteNotes(userId);
}

@riverpod
Stream<List<LibraryFolder>> archivedFolders(ArchivedFoldersRef ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return const Stream.empty();

  return ref.watch(libraryRepositoryProvider).watchArchivedFolders(userId);
}

@riverpod
Stream<List<LibraryFolder>> deletedFolders(DeletedFoldersRef ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return const Stream.empty();

  return ref
      .watch(libraryRepositoryProvider)
      .watchDeletedFolders(userId)
      .map((folders) {
    return folders.where((folder) {
      if (folder.parentId == LibraryFolder.rootId) {
        return true;
      }

      final parentDeleted = folders.any(
            (candidate) =>
        candidate.id == folder.parentId &&
            candidate.isDeleted,
      );

      return !parentDeleted;
    }).toList();
  });
}

@riverpod
Stream<List<NoteItem>> deletedNotes(DeletedNotesRef ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return const Stream.empty();

  return ref.watch(libraryRepositoryProvider).watchDeletedNotes(userId);
}

@riverpod
Stream<List<NoteItem>> notesInFolder(
  NotesInFolderRef ref,
  String folderId,
) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return const Stream.empty();

  return ref.watch(libraryRepositoryProvider).watchNotes(userId, folderId);
}

@Riverpod(keepAlive: true)
class LibraryActionController extends _$LibraryActionController {
  @override
  FutureOr<void> build() {}

  Future<bool> createFolder({
    required String parentId,
    required String name,
  }) {
    return _run((userId, repository) {
      return repository.createFolder(
        userId: userId,
        parentId: parentId,
        name: name,
      );
    });
  }

  Future<bool> renameNote({
    required String noteId,
    required String name,
  }) {
    return _run((userId, repository) {
      return repository.renameNote(
        userId: userId,
        noteId: noteId,
        name: name,
      );
    });
  }

  Future<bool> renameFolder({
    required String folderId,
    required String name,
  }) {
    return _run((userId, repository) {
      return repository.renameFolder(
        userId: userId,
        folderId: folderId,
        name: name,
      );
    });
  }

  Future<bool> createInternalNote({
    required String folderId,
    required String name,
  }) {
    return _run((userId, repository) {
      return repository.createInternalNote(
        userId: userId,
        folderId: folderId,
        name: name,
      );
    });
  }

  Future<bool> setFolderFavorite(LibraryFolder folder, bool value) {
    return _run((userId, repository) {
      return repository.setFolderFavorite(
        userId: userId,
        folderId: folder.id,
        isFavorite: value,
      );
    });
  }

  Future<bool> toggleNoteFavorite(
      NoteItem note,
      ) {
    return _run((userId, repository) {
      return repository.setNoteFavorite(
        userId: userId,
        noteId: note.id,
        isFavorite: !note.isFavorite,
      );
    });
  }

  Future<bool> setFolderArchived(LibraryFolder folder, bool value) {
    return _run((userId, repository) {
      return repository.setFolderArchived(
        userId: userId,
        folderId: folder.id,
        isArchived: value,
      );
    });
  }

  Future<bool> softDeleteFolder(LibraryFolder folder) {
    return _run((userId, repository) {
      return repository.softDeleteFolder(
        userId: userId,
        folderId: folder.id,
      );
    });
  }

  Future<bool> restoreFolder(LibraryFolder folder) {
    return _run((userId, repository) {
      return repository.restoreFolder(
        userId: userId,
        folderId: folder.id,
      );
    });
  }

  Future<bool> uploadNote({
    required String folderId,
    required String fileName,
    required String extension,
    required Uint8List bytes,
    required NoteCategory category,
  }) {
    return _run((userId, repository) {
      return repository.uploadNote(
        userId: userId,
        folderId: folderId,
        fileName: fileName,
        extension: extension,
        bytes: bytes,
        category: category,
      );
    });
  }

  Future<bool> softDeleteNote(NoteItem note) {
    return _run((userId, repository) {
      return repository.softDeleteNote(
        userId: userId,
        noteId: note.id,
      );
    });
  }

  Future<bool> restoreNote(NoteItem note) {
    return _run((userId, repository) {
      return repository.restoreNote(
        userId: userId,
        noteId: note.id,
      );
    });
  }

  Future<bool> updateInternalNote({
    required String noteId,
    required String content,
  }) {
    return _run((userId, repository) {
      return repository.updateInternalNote(
        userId: userId,
        noteId: noteId,
        content: content,
      );
    });
  }

  Future<bool> permanentlyDeleteNote(NoteItem note) {
    return _run((userId, repository) {
      return repository.permanentlyDeleteNote(
        userId: userId,
        noteId: note.id,
      );
    });
  }

  Future<bool> permanentlyDeleteFolder(LibraryFolder folder) {
    return _run((userId, repository) {
      return repository.permanentlyDeleteFolder(
        userId: userId,
        folderId: folder.id,
      );
    });
  }

  Future<bool> _run(
    Future<void> Function(String userId, LibraryRepository repository) action,
  ) async {
    final userId = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (userId == null) {
      state = AsyncValue.error(
        StateError('You must be signed in.'),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncValue.loading();
    try {
      await action(userId, ref.read(libraryRepositoryProvider));
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}
