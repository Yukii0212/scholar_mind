import '../../domain/flashcard_models.dart';

class FlashcardWithDeck {
  const FlashcardWithDeck({
    required this.card,
    required this.deckId,
  });

  final Flashcard card;

  final String deckId;
}
