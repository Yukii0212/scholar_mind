import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/quiz_folder.dart';
import '../domain/quiz_attempt.dart';
import '../domain/quiz_response.dart';

class QuizLibraryRepository {
  QuizLibraryRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _folders(String userId) =>
      _firestore.collection('users').doc(userId).collection('quiz_folders');

  CollectionReference<Map<String, dynamic>> _quizzes(
      String userId,
      ) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('quizzes');

  Stream<List<QuizFolder>> watchChildFolders(
      String userId,
      String parentId,
      ) {
    return _folders(userId)
        .where('parentId', isEqualTo: parentId)
        .where('isArchived', isEqualTo: false)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final folders = snapshot.docs.map(QuizFolder.fromDocument).toList();
      folders.sort(_sortFolders);
      return folders;
    });
  }

  Stream<List<QuizFolder>> watchFavoriteFolders(String userId) {
    return _folders(userId)
        .where('isFavorite', isEqualTo: true)
        .where('isArchived', isEqualTo: false)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final folders = snapshot.docs.map(QuizFolder.fromDocument).toList();
      folders.sort(_sortFolders);
      return folders;
    });
  }

  Stream<List<QuizAttempt>> watchFavoriteQuizzes(
      String userId,
      ) {
    return _quizzes(userId)
        .where('isFavorite', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final quizzes =
      snapshot.docs.map(QuizAttempt.fromDocument).toList();

      quizzes.sort(
            (a, b) =>
            b.createdAt.compareTo(a.createdAt),
      );

      return quizzes;
    });
  }

  Stream<List<QuizFolder>> watchArchivedFolders(String userId) {
    return _folders(userId)
        .where('isArchived', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final folders = snapshot.docs.map(QuizFolder.fromDocument).toList();
      folders.sort(_sortFolders);
      return folders;
    });
  }

  Stream<List<QuizFolder>> watchDeletedFolders(String userId) {
    return _folders(userId)
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final folders = snapshot.docs.map(QuizFolder.fromDocument).toList();
      folders.sort(_sortFolders);
      return folders;
    });
  }

  Stream<List<QuizAttempt>> watchDeletedQuizzes(String userId) {
    return _quizzes(userId)
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final quizzes = snapshot.docs.map(QuizAttempt.fromDocument).toList();

      quizzes.sort(
            (a, b) => (b.deletedAt ?? b.createdAt)
            .compareTo(a.deletedAt ?? a.createdAt),
      );

      return quizzes;
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

    final quizzes = await _quizzes(userId)
        .where('folderId', isEqualTo: parentFolderId)
        .get();

    for (final quiz in quizzes.docs) {
      await quiz.reference.update({
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

    final quizzes = await _quizzes(userId)
        .where('folderId', isEqualTo: parentFolderId)
        .get();

    for (final quiz in quizzes.docs) {
      await quiz.reference.update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> softDeleteQuiz({
    required String userId,
    required String quizId,
  }) {

    return _quizzes(userId).doc(quizId).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> restoreQuiz({
    required String userId,
    required String quizId,
  }) {
    return _quizzes(userId).doc(quizId).update({
      'isDeleted': false,
      'deletedAt': null,
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

    final quizzes = await _quizzes(userId)
        .where('isDeleted', isEqualTo: true)
        .get();

    for (final quiz in quizzes.docs) {
      final folderId = quiz.data()['folderId'] as String;

      final parentDeleted = folders.docs.any(
            (folder) => folder.id == folderId,
      );

      if (!parentDeleted) {
        await restoreQuiz(
          userId: userId,
          quizId: quiz.id,
        );
      }
    }
  }

  Future<void> permanentlyDeleteQuiz({
    required String userId,
    required String quizId,
  }) async {
    await _quizzes(userId)
        .doc(quizId)
        .delete();
  }

  Future<void> renameQuiz({
    required String userId,
    required String quizId,
    required String name,
  }) async {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError(
        'Quiz name cannot be empty.',
      );
    }

    await _quizzes(userId).doc(quizId).update({
      'name': normalizedName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> moveQuiz({
    required String userId,
    required String quizId,
    required String destinationFolderId,
  }) async {
    final quizDoc =
    await _quizzes(userId)
        .doc(quizId)
        .get();

    if (!quizDoc.exists) {
      throw ArgumentError(
        'Quiz not found.',
      );
    }

    final currentFolderId =
    quizDoc.data()?['folderId'];

    if (currentFolderId ==
        destinationFolderId) {
      throw ArgumentError(
        'Quiz is already in that folder.',
      );
    }

    await _quizzes(userId).doc(quizId).update({
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

  Future<void> setQuizFavorite({
    required String userId,
    required String quizId,
    required bool isFavorite,
  }) {
    return _quizzes(userId).doc(quizId).update({
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

    final quizzes = await _quizzes(userId)
        .where('isDeleted', isEqualTo: true)
        .get();

    for (final quiz in quizzes.docs) {
      final folderId = quiz.data()['folderId'] as String;

      final parentDeleted = folders.docs.any(
            (folder) => folder.id == folderId,
      );

      if (!parentDeleted) {
        await permanentlyDeleteQuiz(
          userId: userId,
          quizId: quiz.id,
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

    final quizzes = await _quizzes(userId)
        .where('folderId', isEqualTo: parentFolderId)
        .get();

    for (final quizDoc in quizzes.docs) {
      await quizDoc.reference.delete();
    }
  }

  Stream<List<QuizAttempt>> watchQuizzes(String userId, String folderId) {
    return _quizzes(userId)
        .where('folderId', isEqualTo: folderId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final quizzes = snapshot.docs.map(QuizAttempt.fromDocument).toList();
      quizzes.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
      );
      return quizzes;
    });
  }

  Stream<List<QuizAttempt>> watchActiveQuizzes(
      String userId,
      ) {
    return _quizzes(userId)
        .where(
      'isDeleted',
      isEqualTo: false,
    )
        .snapshots()
        .map((snapshot) {

      final quizzes = snapshot.docs
          .map(QuizAttempt.fromDocument)
          .where(
            (quiz) =>
        quiz.status ==
            QuizAttemptStatus.inProgress ||
            quiz.status ==
                QuizAttemptStatus.grading,
      )
          .toList();

      quizzes.sort(
            (a, b) =>
            b.updatedAt.compareTo(
              a.updatedAt,
            ),
      );

      return quizzes;
    });
  }

  Stream<QuizAttempt> watchQuiz(
      String userId,
      String quizId,
      ) {
    return _quizzes(userId)
        .doc(quizId)
        .snapshots()
        .map((snapshot) {
      return QuizAttempt.fromDocument(snapshot);
    });
  }

  Stream<List<QuizAttempt>> watchAllQuizzes(
      String userId,
      ) {
    return _quizzes(userId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final quizzes =
      snapshot.docs.map(QuizAttempt.fromDocument).toList();

      quizzes.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return quizzes;
    });
  }

  Stream<List<QuizFolder>> watchAllFolders(
      String userId,
      ) {
    return _folders(userId)
        .where('isDeleted', isEqualTo: false)
        .where('isArchived', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final folders =
      snapshot.docs.map(QuizFolder.fromDocument).toList();

      folders.sort(_sortFolders);

      return folders;
    });
  }

  Future<String> createFolder({
    required String userId,
    required String parentId,
    required String name,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('Folder name cannot be empty.');
    }

    final reference = _folders(userId).doc();
    final now = FieldValue.serverTimestamp();

    await reference.set({
      'name': normalizedName,
      'parentId': parentId,
      'isFavorite': false,
      'isArchived': false,
      'isDeleted': false,
      'deletedAt': null,
      'createdAt': now,
      'updatedAt': now,
    });

    return reference.id;
  }

  Future<QuizAttempt?> getQuiz({
    required String userId,
    required String quizId,
  }) async {
    final snapshot = await _quizzes(userId).doc(quizId).get();

    if (!snapshot.exists) return null;

    return QuizAttempt.fromDocument(snapshot);
  }

  Future<QuizFolder?> getFolder({
    required String userId,
    required String folderId,
  }) async {
    final snapshot = await _folders(userId).doc(folderId).get();

    if (!snapshot.exists) return null;

    return QuizFolder.fromDocument(snapshot);
  }

  Future<List<QuizAttempt>> getQuizzesInFolder({
    required String userId,
    required String folderId,
  }) async {
    final snapshot = await _quizzes(userId)
        .where('folderId', isEqualTo: folderId)
        .where('isDeleted', isEqualTo: false)
        .get();

    final quizzes = snapshot.docs.map(QuizAttempt.fromDocument).toList();
    quizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return quizzes;
  }

  Future<List<QuizFolder>> getChildFolders({
    required String userId,
    required String parentFolderId,
  }) async {
    final snapshot = await _folders(userId)
        .where('parentId', isEqualTo: parentFolderId)
        .where('isDeleted', isEqualTo: false)
        .where('isArchived', isEqualTo: false)
        .get();

    final folders = snapshot.docs.map(QuizFolder.fromDocument).toList();
    folders.sort(_sortFolders);
    return folders;
  }

  Future<String> importQuiz({
    required String userId,
    required String folderId,
    required String name,
    required QuizResponse quiz,
  }) async {
    final reference = _quizzes(userId).doc();
    final now = DateTime.now();

    final attempt = QuizAttempt(
      id: reference.id,
      quiz: quiz,
      answers: const {},
      status: QuizAttemptStatus.inProgress,
      startedAt: now,
      name: name,
      folderId: folderId,
      createdAt: now,
      updatedAt: now,
    );

    await reference.set(attempt.toJson());

    return reference.id;
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

  Future<void> createQuiz({
    required String userId,
    required QuizAttempt quiz,
  }) async {
    await _quizzes(userId).doc(quiz.id).set(
      quiz.toJson(),
    );
  }

  Future<List<QuizFolder>> getFolderPath({
    required String userId,
    required String folderId,
  }) async {

    if (folderId == QuizFolder.rootId) {
      return [];
    }

    final path = <QuizFolder>[];

    String currentFolderId = folderId;

    while (currentFolderId != QuizFolder.rootId) {

      final snapshot = await _folders(userId)
          .doc(currentFolderId)
          .get();

      if (!snapshot.exists) {
        break;
      }

      final folder =
      QuizFolder.fromDocument(snapshot);

      path.insert(0, folder);

      currentFolderId = folder.parentId;

    }

    return path;

  }

  static int _sortFolders(QuizFolder a, QuizFolder b) {
    if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
