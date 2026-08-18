import '../../domain/flashcard_models.dart';

class FlashcardWithSet {
  const FlashcardWithSet({
    required this.card,
    required this.setId,
  });

  final Flashcard card;

  final String setId;
}
