import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/flashcard_repository.dart';
import '../domain/flashcard_folder.dart';
import '../domain/flashcard_models.dart';

final flashcardRepositoryProvider = Provider<FlashcardRepository>(
  (ref) => FlashcardRepository(FirebaseFirestore.instance),
);

final flashcardSetsProvider = StreamProvider<List<FlashcardSet>>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  return ref.watch(flashcardRepositoryProvider).watchSets(userId);
});

final flashcardsProvider =
    StreamProvider.family<List<Flashcard>, String>((ref, setId) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  return ref.watch(flashcardRepositoryProvider).watchCards(userId, setId);
});

final flashcardSetsInFolderProvider =
    StreamProvider.family<List<FlashcardSet>, String>((ref, folderId) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) return Stream.value(const []);

  return ref
      .watch(flashcardRepositoryProvider)
      .watchSetsInFolder(userId, folderId);
});

final flashcardChildFoldersProvider =
    StreamProvider.family<List<FlashcardFolder>, String>((ref, parentId) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) return Stream.value(const []);

  return ref
      .watch(flashcardRepositoryProvider)
      .watchChildFolders(userId, parentId);
});

final flashcardAllFoldersProvider =
    StreamProvider<List<FlashcardFolder>>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) return Stream.value(const []);

  return ref.watch(flashcardRepositoryProvider).watchAllFolders(userId);
});

final flashcardDeletedFoldersProvider =
    StreamProvider<List<FlashcardFolder>>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) return Stream.value(const []);

  return ref.watch(flashcardRepositoryProvider).watchDeletedFolders(userId);
});

final flashcardDeletedSetsProvider = StreamProvider<List<FlashcardSet>>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) return Stream.value(const []);

  return ref.watch(flashcardRepositoryProvider).watchDeletedSets(userId);
});

final flashcardFolderPathProvider =
    FutureProvider.family<List<FlashcardFolder>, String>((ref, folderId) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) return Future.value(const []);

  return ref
      .watch(flashcardRepositoryProvider)
      .getFolderPath(userId: userId, folderId: folderId);
});

class FlashcardLibraryActionController extends StateNotifier<AsyncValue<void>> {
  FlashcardLibraryActionController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> createFolder({required String parentId, required String name}) {
    return _run(
      (userId, repository) =>
          repository.createFolder(userId: userId, parentId: parentId, name: name),
    );
  }

  Future<bool> renameFolder({required String folderId, required String name}) {
    return _run(
      (userId, repository) =>
          repository.renameFolder(userId: userId, folderId: folderId, name: name),
    );
  }

  Future<bool> moveFolder({
    required String folderId,
    required String destinationFolderId,
  }) {
    return _run(
      (userId, repository) => repository.moveFolder(
        userId: userId,
        folderId: folderId,
        destinationFolderId: destinationFolderId,
      ),
    );
  }

  Future<bool> moveSet({
    required String setId,
    required String destinationFolderId,
  }) {
    return _run(
      (userId, repository) => repository.moveSet(
        userId: userId,
        setId: setId,
        destinationFolderId: destinationFolderId,
      ),
    );
  }

  Future<bool> softDeleteFolder(FlashcardFolder folder) {
    return _run(
      (userId, repository) =>
          repository.softDeleteFolder(userId: userId, folderId: folder.id),
    );
  }

  Future<bool> restoreFolder(FlashcardFolder folder) {
    return _run(
      (userId, repository) =>
          repository.restoreFolder(userId: userId, folderId: folder.id),
    );
  }

  Future<bool> permanentlyDeleteFolder(FlashcardFolder folder) {
    return _run(
      (userId, repository) =>
          repository.permanentlyDeleteFolder(userId: userId, folderId: folder.id),
    );
  }

  Future<bool> softDeleteSet(FlashcardSet set) {
    return _run(
      (userId, repository) =>
          repository.softDeleteSet(userId: userId, setId: set.id),
    );
  }

  Future<bool> restoreSet(FlashcardSet set) {
    return _run(
      (userId, repository) => repository.restoreSet(userId: userId, setId: set.id),
    );
  }

  Future<bool> permanentlyDeleteSet(FlashcardSet set) {
    return _run(
      (userId, repository) => repository.deleteSet(userId: userId, setId: set.id),
    );
  }

  Future<bool> restoreAll() {
    return _run((userId, repository) => repository.restoreAll(userId: userId));
  }

  Future<bool> permanentlyDeleteAll() {
    return _run(
      (userId, repository) => repository.permanentlyDeleteAll(userId: userId),
    );
  }

  Future<bool> _run(
    Future<void> Function(String userId, FlashcardRepository repository) action,
  ) async {
    final userId = _ref.read(firebaseAuthProvider).currentUser?.uid;
    if (userId == null) {
      state = AsyncValue.error(
        StateError('You must be signed in.'),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncValue.loading();
    try {
      await action(userId, _ref.read(flashcardRepositoryProvider));
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

final flashcardLibraryActionControllerProvider =
    StateNotifierProvider<FlashcardLibraryActionController, AsyncValue<void>>(
  (ref) => FlashcardLibraryActionController(ref),
);
