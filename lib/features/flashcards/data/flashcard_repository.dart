import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/flashcard_models.dart';

class FlashcardRepository {
  const FlashcardRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _decks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('flashcard_decks');
  }

  CollectionReference<Map<String, dynamic>> _cards(
    String userId,
    String deckId,
  ) {
    return _decks(userId).doc(deckId).collection('cards');
  }

  Stream<List<FlashcardDeck>> watchDecks(String? userId) {
    if (userId == null) return Stream.value(const []);

    return _decks(userId).snapshots().map((snapshot) {
      final decks = snapshot.docs.map(FlashcardDeck.fromFirestore).toList();
      decks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return decks;
    });
  }

  Stream<List<Flashcard>> watchCards(String? userId, String deckId) {
    if (userId == null) return Stream.value(const []);

    return _cards(userId, deckId).snapshots().map((snapshot) {
      final cards = snapshot.docs.map(Flashcard.fromFirestore).toList();
      cards.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return cards;
    });
  }

  Future<String> saveDeck({
    required String userId,
    String? deckId,
    required String name,
    required List<String> tags,
    required FlashcardGenerationMethod generationMethod,
    required String? sourceReference,
    required String? description,
  }) async {
    final reference =
        deckId == null ? _decks(userId).doc() : _decks(userId).doc(deckId);
    final existing = deckId == null ? null : await reference.get();
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
        'createdAt': existingData?['createdAt'] as Timestamp? ?? now,
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );

    return reference.id;
  }

  Future<void> deleteDeck({
    required String userId,
    required String deckId,
  }) async {
    final cards = await _cards(userId, deckId).get();
    final batch = _firestore.batch();
    for (final card in cards.docs) {
      batch.delete(card.reference);
    }
    batch.delete(_decks(userId).doc(deckId));
    await batch.commit();
  }

  Future<void> saveCard({
    required String userId,
    required String deckId,
    String? cardId,
    required String front,
    required String back,
    required List<String> tags,
    String? frontImageUrl,
    String? backImageUrl,
  }) async {
    final reference = cardId == null
        ? _cards(userId, deckId).doc()
        : _cards(userId, deckId).doc(cardId);
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

    await _refreshDeckMetadata(userId, deckId);
  }

  Future<void> saveGeneratedDeck({
    required String userId,
    required GeneratedFlashcardDeck generated,
    required List<String> tags,
    required String? sourceReference,
    required String? description,
  }) async {
    final deckId = await saveDeck(
      userId: userId,
      name: generated.title,
      tags: tags,
      generationMethod: FlashcardGenerationMethod.aiGenerated,
      sourceReference: sourceReference,
      description: description,
    );

    final batch = _firestore.batch();
    final now = Timestamp.fromDate(DateTime.now());
    for (final card in generated.cards) {
      final reference = _cards(userId, deckId).doc();
      batch.set(reference, {
        'front': card.front,
        'back': card.back,
        'tags': _cleanTags([...tags, ...card.tags]),
        'frontImageUrl': null,
        'backImageUrl': null,
        'createdAt': now,
        'updatedAt': now,
      });
    }
    batch.update(_decks(userId).doc(deckId), {
      'cardCount': generated.cards.length,
      'updatedAt': now,
    });
    await batch.commit();
  }

  Future<void> deleteCard({
    required String userId,
    required String deckId,
    required String cardId,
  }) async {
    await _cards(userId, deckId).doc(cardId).delete();
    await _refreshDeckMetadata(userId, deckId);
  }

  Future<void> recordSession({
    required String userId,
    required String deckId,
    required int reviewed,
    required int known,
    required int needsReview,
  }) {
    return _decks(userId).doc(deckId).update({
      'sessionsCompleted': FieldValue.increment(1),
      'cardsReviewed': FieldValue.increment(reviewed),
      'knownCards': FieldValue.increment(known),
      'needsReviewCards': FieldValue.increment(needsReview),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> _refreshDeckMetadata(String userId, String deckId) async {
    final cards = await _cards(userId, deckId).get();
    await _decks(userId).doc(deckId).update({
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
}
