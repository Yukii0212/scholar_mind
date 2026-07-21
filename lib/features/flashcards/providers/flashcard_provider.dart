import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/flashcard_repository.dart';
import '../domain/flashcard_models.dart';

final flashcardRepositoryProvider = Provider<FlashcardRepository>(
  (ref) => FlashcardRepository(FirebaseFirestore.instance),
);

final flashcardDecksProvider = StreamProvider<List<FlashcardDeck>>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  return ref.watch(flashcardRepositoryProvider).watchDecks(userId);
});

final flashcardsProvider =
    StreamProvider.family<List<Flashcard>, String>((ref, deckId) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  return ref.watch(flashcardRepositoryProvider).watchCards(userId, deckId);
});
