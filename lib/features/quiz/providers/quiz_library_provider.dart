import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/quiz_library_repository.dart';
import '../domain/quiz_folder.dart';
import '../domain/quiz_attempt.dart';

part 'quiz_library_provider.g.dart';

@Riverpod(keepAlive: true)
QuizLibraryRepository
quizLibraryRepository(
    QuizLibraryRepositoryRef ref,
    ) {
  return QuizLibraryRepository(
    FirebaseFirestore.instance,
  );
}
@riverpod
Stream<List<QuizFolder>> childFolders(
    ChildFoldersRef ref,
    String parentId,
    ) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return const Stream.empty();

  return ref
      .watch(quizLibraryRepositoryProvider)
      .watchChildFolders(userId, parentId);
}

@riverpod
Stream<List<QuizFolder>> allFolders(
    AllFoldersRef ref,
    ) {
  final userId =
      ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) {
    return const Stream.empty();
  }

  return ref
      .watch(quizLibraryRepositoryProvider)
      .watchAllFolders(userId);
}

@riverpod
Stream<List<QuizFolder>> favoriteFolders(FavoriteFoldersRef ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return const Stream.empty();

  return ref.watch(quizLibraryRepositoryProvider).watchFavoriteFolders(userId);
}

@riverpod
Stream<List<QuizAttempt>> favoriteQuizzes(
    FavoriteQuizzesRef ref,
    ) {
  final userId =
      ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) {
    return const Stream.empty();
  }

  return ref
      .watch(quizLibraryRepositoryProvider)
      .watchFavoriteQuizzes(userId);
}

@riverpod
Stream<List<QuizFolder>> archivedFolders(ArchivedFoldersRef ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return const Stream.empty();

  return ref.watch(quizLibraryRepositoryProvider).watchArchivedFolders(userId);
}

@riverpod
Stream<List<QuizFolder>> deletedFolders(DeletedFoldersRef ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return const Stream.empty();

  return ref
      .watch(quizLibraryRepositoryProvider)
      .watchDeletedFolders(userId)
      .map((folders) {
    return folders.where((folder) {
      if (folder.parentId == QuizFolder.rootId) {
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
Stream<List<QuizAttempt>> deletedQuizzes(DeletedQuizzesRef ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return const Stream.empty();

  return ref.watch(quizLibraryRepositoryProvider).watchDeletedQuizzes(userId);
}

@riverpod
Stream<List<QuizAttempt>> quizzesInFolder(
    QuizzesInFolderRef ref,
    String folderId,
    ) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return const Stream.empty();

  return ref.watch(quizLibraryRepositoryProvider).watchQuizzes(userId, folderId);
}

@riverpod
Stream<QuizAttempt> quiz(
    QuizRef ref,
    String quizId,
    ) {
  final userId =
      ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) {
    return const Stream.empty();
  }

  return ref
      .watch(quizLibraryRepositoryProvider)
      .watchQuiz(
    userId,
    quizId,
  );
}

@Riverpod(keepAlive: true)
class QuizLibraryActionController extends _$QuizLibraryActionController {
  @override
  FutureOr<void> build() {}

  Future<bool> createQuizFolder({
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

  Future<bool> renameQuiz({
    required String quizId,
    required String name,
  }) {
    return _run((userId, repository) {
      return repository.renameQuiz(
        userId: userId,
        quizId: quizId,
        name: name,
      );
    });
  }

  Future<bool> renameQuizFolder({
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

  Future<bool> moveQuizFolder({
    required String folderId,
    required String destinationFolderId,
  }) {
    return _run((userId, repository) {
      return repository.moveFolder(
        userId: userId,
        folderId: folderId,
        destinationFolderId:
        destinationFolderId,
      );
    });
  }

  Future<bool> moveQuiz({
    required String quizId,
    required String destinationFolderId,
  }) {
    return _run((userId, repository) {
      return repository.moveQuiz(
        userId: userId,
        quizId: quizId,
        destinationFolderId:
        destinationFolderId,
      );
    });
  }

  Future<bool> setQuizFolderFavorite(QuizFolder folder, bool value) {
    return _run((userId, repository) {
      return repository.setFolderFavorite(
        userId: userId,
        folderId: folder.id,
        isFavorite: value,
      );
    });
  }

  Future<bool> toggleQuizFavorite(
      QuizAttempt quiz,
      ) {
    return _run((userId, repository) {
      return repository.setQuizFavorite(
        userId: userId,
        quizId: quiz.id,
        isFavorite: !quiz.isFavorite,
      );
    });
  }

  Future<bool> setQuizFolderArchived(QuizFolder folder, bool value) {
    return _run((userId, repository) {
      return repository.setFolderArchived(
        userId: userId,
        folderId: folder.id,
        isArchived: value,
      );
    });
  }

  Future<bool> softDeleteQuizFolder(QuizFolder folder) {
    return _run((userId, repository) {
      return repository.softDeleteFolder(
        userId: userId,
        folderId: folder.id,
      );
    });
  }

  Future<bool> restoreQuizFolder(QuizFolder folder) {
    return _run((userId, repository) {
      return repository.restoreFolder(
        userId: userId,
        folderId: folder.id,
      );
    });
  }

  Future<bool> softDeleteQuiz(
      QuizAttempt quiz,
      ) async {

    final success = await _run(
          (userId, repository) {
        return repository.softDeleteQuiz(
          userId: userId,
          quizId: quiz.id,
        );
      },
    );

    return success;
  }

  Future<bool> restoreQuiz(
      QuizAttempt quiz,
      ) async {

    final success = await _run(
          (userId, repository) {
        return repository.restoreQuiz(
          userId: userId,
          quizId: quiz.id,
        );
      },
    );
    return success;
  }

  Future<bool> restoreAll() {
    return _run((userId, repository) {
      return repository.restoreAll(
        userId: userId,
      );
    });
  }

  Future<bool> permanentlyDeleteQuiz(
      QuizAttempt quiz,
      ) async {
    final success = await _run(
          (userId, repository) {
        return repository.permanentlyDeleteQuiz(
          userId: userId,
          quizId: quiz.id,
        );
      },
    );

    return success;
  }

  Future<bool> permanentlyDeleteFolder(QuizFolder folder) {
    return _run((userId, repository) {
      return repository.permanentlyDeleteFolder(
        userId: userId,
        folderId: folder.id,
      );
    });
  }

  Future<bool> permanentlyDeleteAll() {
    return _run((userId, repository) {
      return repository.permanentlyDeleteAll(
        userId: userId,
      );
    });
  }

  Future<bool> _run(
      Future<void> Function(
          String userId,
          QuizLibraryRepository repository,
          ) action,
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
      await action(userId, ref.read(quizLibraryRepositoryProvider));
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}
