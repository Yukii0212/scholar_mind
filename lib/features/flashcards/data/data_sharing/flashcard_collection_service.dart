import '../../../data_sharing/collection/data_share_collector.dart';
import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/collection/collection_result.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../flashcard_repository.dart';
import 'flashcard_with_deck.dart';

class FlashcardCollectionService implements DataShareCollector {
  FlashcardCollectionService({
    required this.repository,
  });

  final FlashcardRepository repository;

  @override
  ShareResourceType get resourceType => ShareResourceType.flashcardDeck;

  @override
  Future<CollectionResult> collect({
    required String userId,
    required List<String> resourceIds,
  }) async {
    final resources = <CollectedResource>[];
    final visitedDecks = <String>{};

    for (final deckId in resourceIds) {
      if (!visitedDecks.add(deckId)) {
        continue;
      }

      final deck = await repository.getDeck(
        userId: userId,
        deckId: deckId,
      );

      if (deck == null) {
        continue;
      }

      resources.add(
        CollectedResource(
          resourceType: ShareResourceType.flashcardDeck,
          resourceId: deck.id,
          data: deck,
        ),
      );

      final cards = await repository.getCardsInDeck(
        userId: userId,
        deckId: deck.id,
      );

      for (final card in cards) {
        resources.add(
          CollectedResource(
            resourceType: ShareResourceType.flashcard,
            resourceId: card.id,
            data: FlashcardWithDeck(
              card: card,
              deckId: deck.id,
            ),
          ),
        );
      }
    }

    return CollectionResult(resources: resources);
  }
}
