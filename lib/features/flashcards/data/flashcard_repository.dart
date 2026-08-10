import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/flashcard_folder.dart';
import '../domain/flashcard_models.dart';

class FlashcardRepository {
  const FlashcardRepository(this._firestore);

  final FirebaseFirestore _firestore;

  // Collection path stays 'flashcard_decks'/'cards' -- renaming the
  // Firestore-level path would orphan existing users' real data, unlike
  // the Dart-side identifiers below which are purely cosmetic.
  CollectionReference<Map<String, dynamic>> _sets(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('flashcard_decks');
  }

  CollectionReference<Map<String, dynamic>> _folders(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('flashcard_folders');
  }

  CollectionReference<Map<String, dynamic>> _cards(
    String userId,
    String setId,
  ) {
    return _sets(userId).doc(setId).collection('cards');
  }

  CollectionReference<Map<String, dynamic>> _sessions(
    String userId,
    String setId,
  ) {
    return _sets(userId).doc(setId).collection('sessions');
  }

  // ---------------------------------------------------------------------
  // Sets
  // ---------------------------------------------------------------------

  Stream<List<FlashcardSet>> watchSets(String? userId) {
    if (userId == null) return Stream.value(const []);

    return _sets(userId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final sets = snapshot.docs.map(FlashcardSet.fromFirestore).toList();
      sets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return sets;
    });
  }

  Stream<List<FlashcardSet>> watchSetsInFolder(
    String userId,
    String folderId,
  ) {
    return _sets(userId)
        .where('folderId', isEqualTo: folderId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final sets = snapshot.docs.map(FlashcardSet.fromFirestore).toList();
      sets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return sets;
    });
  }

  Stream<List<Flashcard>> watchCards(String? userId, String setId) {
    if (userId == null) return Stream.value(const []);

    return _cards(userId, setId).snapshots().map((snapshot) {
      final cards = snapshot.docs.map(Flashcard.fromFirestore).toList();
      cards.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return cards;
    });
  }

  Future<FlashcardSet?> getSet({
    required String userId,
    required String setId,
  }) async {
    final snapshot = await _sets(userId).doc(setId).get();

    if (!snapshot.exists) return null;

    return FlashcardSet.fromFirestore(snapshot);
  }

  Future<Flashcard?> getCard({
    required String userId,
    required String setId,
    required String cardId,
  }) async {
    final snapshot = await _cards(userId, setId).doc(cardId).get();

    if (!snapshot.exists) return null;

    return Flashcard.fromFirestore(snapshot);
  }

  Future<List<Flashcard>> getCardsInSet({
    required String userId,
    required String setId,
  }) async {
    final snapshot = await _cards(userId, setId).get();

    final cards = snapshot.docs.map(Flashcard.fromFirestore).toList();
    cards.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return cards;
  }

  Future<String> saveSet({
    required String userId,
    String? setId,
    required String name,
    required List<String> tags,
    required FlashcardGenerationMethod generationMethod,
    required String? sourceReference,
    required String? description,
    String? folderId,
  }) async {
    final reference =
        setId == null ? _sets(userId).doc() : _sets(userId).doc(setId);
    final existing = setId == null ? null : await reference.get();
    final existingData = existing?.data();
    final now = Timestamp.fromDate(DateTime.now());

    await reference.set(
      {
        'name': name,
        'tags': _cleanTags(tags),
        'generationMethod': generationMethod.name,
        'sourceReference': sourceReference,
        'description': description,
        'cardCount': existingData?['cardCount'] as int? ?? 0,
        'sessionsCompleted': existingData?['sessionsCompleted'] as int? ?? 0,
        'cardsReviewed': existingData?['cardsReviewed'] as int? ?? 0,
        'knownCards': existingData?['knownCards'] as int? ?? 0,
        'needsReviewCards': existingData?['needsReviewCards'] as int? ?? 0,
        'folderId': folderId ??
            existingData?['folderId'] as String? ??
            FlashcardFolder.rootId,
        'isDeleted': existingData?['isDeleted'] as bool? ?? false,
        'deletedAt': existingData?['deletedAt'],
        'deletedAsCascade':
            existingData?['deletedAsCascade'] as bool? ?? false,
        'createdAt': existingData?['createdAt'] as Timestamp? ?? now,
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );

    return reference.id;
  }

  /// Permanently deletes a set and its cards -- only reachable from the
  /// Trash (see softDeleteSet for the normal delete path).
  Future<void> deleteSet({
    required String userId,
    required String setId,
  }) async {
    final cards = await _cards(userId, setId).get();
    final batch = _firestore.batch();
    for (final card in cards.docs) {
      batch.delete(card.reference);
    }
    batch.delete(_sets(userId).doc(setId));
    await batch.commit();
  }

  Future<void> softDeleteSet({
    required String userId,
    required String setId,
  }) {
    return _sets(userId).doc(setId).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'deletedAsCascade': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> restoreSet({
    required String userId,
    required String setId,
  }) {
    return _sets(userId).doc(setId).update({
      'isDeleted': false,
      'deletedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> moveSet({
    required String userId,
    required String setId,
    required String destinationFolderId,
  }) async {
    final doc = await _sets(userId).doc(setId).get();

    if (!doc.exists) {
      throw ArgumentError('Set not found.');
    }

    if (doc.data()?['folderId'] == destinationFolderId) {
      throw ArgumentError('Set is already in that folder.');
    }

    await _sets(userId).doc(setId).update({
      'folderId': destinationFolderId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveCard({
    required String userId,
    required String setId,
    String? cardId,
    required String front,
    required String back,
    required List<String> tags,
    String? frontImageUrl,
    String? backImageUrl,
  }) async {
    final reference = cardId == null
        ? _cards(userId, setId).doc()
        : _cards(userId, setId).doc(cardId);
    final existing = cardId == null ? null : await reference.get();
    final createdAt = existing?.data()?['createdAt'] as Timestamp?;
    final now = Timestamp.fromDate(DateTime.now());

    await reference.set({
      'front': front,
      'back': back,
      'tags': _cleanTags(tags),
      'frontImageUrl': frontImageUrl,
      'backImageUrl': backImageUrl,
      'createdAt': createdAt ?? now,
      'updatedAt': now,
    });

    await _refreshSetMetadata(userId, setId);
  }

  Future<void> saveGeneratedSet({
    required String userId,
    required GeneratedFlashcardSet generated,
    required List<String> tags,
    required String? sourceReference,
    required String? description,
    String? folderId,
    void Function(String message)? onProgress,
  }) async {
    onProgress?.call('Creating flashcard set...');

    final setId = await saveSet(
      userId: userId,
      name: generated.title,
      tags: tags,
      generationMethod: FlashcardGenerationMethod.aiGenerated,
      sourceReference: sourceReference,
      description: description,
      folderId: folderId,
    );

    final batch = _firestore.batch();
    final now = Timestamp.fromDate(DateTime.now());

    for (var i = 0; i < generated.cards.length; i++) {
      final card = generated.cards[i];

      onProgress?.call(
        'Saving ${i + 1} of ${generated.cards.length}',
      );

      final reference = _cards(userId, setId).doc();

      batch.set(reference, {
        'front': card.front,
        'back': card.back,
        'tags': _cleanTags([
          ...tags,
          ...card.tags,
        ]),
        'frontImageUrl': null,
        'backImageUrl': null,
        'createdAt': now,
        'updatedAt': now,
      });
    }

    batch.update(
      _sets(userId).doc(setId),
      {
        'cardCount': generated.cards.length,
        'updatedAt': now,
      },
    );

    await batch.commit();
  }

  Future<void> deleteCard({
    required String userId,
    required String setId,
    required String cardId,
  }) async {
    await _cards(userId, setId).doc(cardId).delete();
    await _refreshSetMetadata(userId, setId);
  }

  Future<void> recordSession({
    required String userId,
    required String setId,
    required int reviewed,
    required int known,
    required int needsReview,
    List<String> missedCardIds = const [],
  }) async {
    await _sets(userId).doc(setId).update({
      'sessionsCompleted': FieldValue.increment(1),
      'cardsReviewed': FieldValue.increment(reviewed),
      'knownCards': FieldValue.increment(known),
      'needsReviewCards': FieldValue.increment(needsReview),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    // A per-session record (not just the set's running totals above) so
    // which specific cards keep coming back missed can be surfaced later,
    // the same way quiz feedback tracks specific flagged questions rather
    // than just an aggregate count.
    await _sessions(userId, setId).add({
      'reviewed': reviewed,
      'known': known,
      'needsReview': needsReview,
      'missedCardIds': missedCardIds,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Newest-first session history for a set -- e.g. to find cards that
  /// keep showing up in missedCardIds across sessions.
  Stream<List<Map<String, dynamic>>> watchSessions(
    String userId,
    String setId,
  ) {
    return _sessions(userId, setId)
        .orderBy('completedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> _refreshSetMetadata(String userId, String setId) async {
    final cards = await _cards(userId, setId).get();
    await _sets(userId).doc(setId).update({
      'cardCount': cards.size,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  List<String> _cleanTags(List<String> tags) {
    return tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .take(12)
        .toList();
  }

  // ---------------------------------------------------------------------
  // Folders
  // ---------------------------------------------------------------------

  Stream<List<FlashcardFolder>> watchChildFolders(
    String userId,
    String parentId,
  ) {
    return _folders(userId)
        .where('parentId', isEqualTo: parentId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final folders =
          snapshot.docs.map(FlashcardFolder.fromDocument).toList();
      folders.sort(_sortFolders);
      return folders;
    });
  }

  Stream<List<FlashcardFolder>> watchAllFolders(String userId) {
    return _folders(userId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final folders =
          snapshot.docs.map(FlashcardFolder.fromDocument).toList();
      folders.sort(_sortFolders);
      return folders;
    });
  }

  /// Trashed folders that the user directly deleted -- excludes folders
  /// only in the trash because an ancestor was deleted (deletedAsCascade).
  Stream<List<FlashcardFolder>> watchDeletedFolders(String userId) {
    return _folders(userId)
        .where('isDeleted', isEqualTo: true)
        .where('deletedAsCascade', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final folders =
          snapshot.docs.map(FlashcardFolder.fromDocument).toList();
      folders.sort(
        (a, b) => (b.deletedAt ?? b.createdAt)
            .compareTo(a.deletedAt ?? a.createdAt),
      );
      return folders;
    });
  }

  /// Same as watchDeletedFolders but for sets -- see FlashcardFolder
  /// .deletedAsCascade for why this filter exists.
  Stream<List<FlashcardSet>> watchDeletedSets(String userId) {
    return _sets(userId)
        .where('isDeleted', isEqualTo: true)
        .where('deletedAsCascade', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final sets = snapshot.docs.map(FlashcardSet.fromFirestore).toList();
      sets.sort(
        (a, b) => (b.deletedAt ?? b.createdAt)
            .compareTo(a.deletedAt ?? a.createdAt),
      );
      return sets;
    });
  }

  Future<FlashcardFolder?> getFolder({
    required String userId,
    required String folderId,
  }) async {
    final snapshot = await _folders(userId).doc(folderId).get();

    if (!snapshot.exists) return null;

    return FlashcardFolder.fromDocument(snapshot);
  }

  Future<List<FlashcardFolder>> getChildFolders({
    required String userId,
    required String parentFolderId,
  }) async {
    final snapshot = await _folders(userId)
        .where('parentId', isEqualTo: parentFolderId)
        .where('isDeleted', isEqualTo: false)
        .get();

    final folders = snapshot.docs.map(FlashcardFolder.fromDocument).toList();
    folders.sort(_sortFolders);
    return folders;
  }

  Future<List<FlashcardFolder>> getFolderPath({
    required String userId,
    required String folderId,
  }) async {
    if (folderId == FlashcardFolder.rootId) {
      return [];
    }

    final path = <FlashcardFolder>[];
    var currentFolderId = folderId;

    while (currentFolderId != FlashcardFolder.rootId) {
      final snapshot = await _folders(userId).doc(currentFolderId).get();

      if (!snapshot.exists) break;

      final folder = FlashcardFolder.fromDocument(snapshot);
      path.insert(0, folder);
      currentFolderId = folder.parentId;
    }

    return path;
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
      'isDeleted': false,
      'deletedAt': null,
      'deletedAsCascade': false,
      'createdAt': now,
      'updatedAt': now,
    });

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

  Future<void> moveFolder({
    required String userId,
    required String folderId,
    required String destinationFolderId,
  }) async {
    if (folderId == destinationFolderId) {
      throw ArgumentError('A folder cannot be moved into itself.');
    }

    final folderDoc = await _folders(userId).doc(folderId).get();

    if (!folderDoc.exists) {
      throw ArgumentError('Folder not found.');
    }

    if (folderDoc.data()?['parentId'] == destinationFolderId) {
      throw ArgumentError('Folder is already in that location.');
    }

    final descendants = await _getDescendantFolderIds(userId, folderId);

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
      descendants.addAll(await _getDescendantFolderIds(userId, child.id));
    }

    return descendants;
  }

  /// Soft-deletes a folder and recursively cascades to every subfolder
  /// and set inside it -- only the folder itself is marked as a direct
  /// deletion (deletedAsCascade: false); everything cascaded gets
  /// deletedAsCascade: true so Trash only lists this one entry.
  Future<void> softDeleteFolder({
    required String userId,
    required String folderId,
  }) async {
    final now = FieldValue.serverTimestamp();

    await _folders(userId).doc(folderId).update({
      'isDeleted': true,
      'deletedAt': now,
      'deletedAsCascade': false,
      'updatedAt': now,
    });

    await _cascadeDelete(userId: userId, parentFolderId: folderId);
  }

  Future<void> _cascadeDelete({
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
        'deletedAsCascade': true,
        'updatedAt': now,
      });

      await _cascadeDelete(userId: userId, parentFolderId: folder.id);
    }

    final sets =
        await _sets(userId).where('folderId', isEqualTo: parentFolderId).get();

    for (final set in sets.docs) {
      await set.reference.update({
        'isDeleted': true,
        'deletedAt': now,
        'deletedAsCascade': true,
        'updatedAt': now,
      });
    }
  }

  /// Restores a folder and recursively restores everything that was
  /// cascaded into the trash along with it.
  Future<void> restoreFolder({
    required String userId,
    required String folderId,
  }) async {
    await _folders(userId).doc(folderId).update({
      'isDeleted': false,
      'deletedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _cascadeRestore(userId: userId, parentFolderId: folderId);
  }

  Future<void> _cascadeRestore({
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

      await _cascadeRestore(userId: userId, parentFolderId: folder.id);
    }

    final sets =
        await _sets(userId).where('folderId', isEqualTo: parentFolderId).get();

    for (final set in sets.docs) {
      await set.reference.update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Permanently deletes a folder, recursively, including every
  /// subfolder and set (and their cards) inside it.
  Future<void> permanentlyDeleteFolder({
    required String userId,
    required String folderId,
  }) async {
    await _cascadePermanentDelete(userId: userId, parentFolderId: folderId);
    await _folders(userId).doc(folderId).delete();
  }

  Future<void> _cascadePermanentDelete({
    required String userId,
    required String parentFolderId,
  }) async {
    final childFolders = await _folders(userId)
        .where('parentId', isEqualTo: parentFolderId)
        .get();

    for (final folder in childFolders.docs) {
      await _cascadePermanentDelete(userId: userId, parentFolderId: folder.id);
      await folder.reference.delete();
    }

    final sets =
        await _sets(userId).where('folderId', isEqualTo: parentFolderId).get();

    for (final set in sets.docs) {
      await deleteSet(userId: userId, setId: set.id);
    }
  }

  /// Restores everything currently in the Trash (top-level trashed
  /// folders/sets only -- restoring a folder already cascades to its
  /// children via restoreFolder).
  Future<void> restoreAll({required String userId}) async {
    final folders = await _folders(userId)
        .where('isDeleted', isEqualTo: true)
        .get();

    for (final folder in folders.docs) {
      final parentId = folder.data()['parentId'] as String;

      final parentDeleted = folders.docs.any(
        (candidate) =>
            candidate.id == parentId && candidate.data()['isDeleted'] == true,
      );

      if (!parentDeleted) {
        await restoreFolder(userId: userId, folderId: folder.id);
      }
    }

    final sets =
        await _sets(userId).where('isDeleted', isEqualTo: true).get();

    for (final set in sets.docs) {
      final folderId = set.data()['folderId'] as String;

      final parentDeleted =
          folders.docs.any((folder) => folder.id == folderId);

      if (!parentDeleted) {
        await restoreSet(userId: userId, setId: set.id);
      }
    }
  }

  /// Permanently deletes everything currently in the Trash (top-level
  /// trashed folders/sets only -- permanentlyDeleteFolder already cascades
  /// to children).
  Future<void> permanentlyDeleteAll({required String userId}) async {
    final folders = await _folders(userId)
        .where('isDeleted', isEqualTo: true)
        .get();

    for (final folder in folders.docs) {
      final parentId = folder.data()['parentId'] as String;

      final parentDeleted = folders.docs.any(
        (candidate) =>
            candidate.id == parentId && candidate.data()['isDeleted'] == true,
      );

      if (!parentDeleted) {
        await permanentlyDeleteFolder(userId: userId, folderId: folder.id);
      }
    }

    final sets =
        await _sets(userId).where('isDeleted', isEqualTo: true).get();

    for (final set in sets.docs) {
      final folderId = set.data()['folderId'] as String;

      final parentDeleted =
          folders.docs.any((folder) => folder.id == folderId);

      if (!parentDeleted) {
        await deleteSet(userId: userId, setId: set.id);
      }
    }
  }

  static int _sortFolders(FlashcardFolder a, FlashcardFolder b) {
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
