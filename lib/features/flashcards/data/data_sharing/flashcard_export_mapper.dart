import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_metadata.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../domain/flashcard_models.dart';
import 'flashcard_with_deck.dart';

class FlashcardExportMapper {
  const FlashcardExportMapper();

  ShareResource toResource(
      CollectedResource resource,
      ) {
    switch (resource.resourceType) {
      case ShareResourceType.flashcardDeck:
        return _deck(
          resource.asType<FlashcardDeck>(),
        );

      case ShareResourceType.flashcard:
        return _card(
          resource.asType<FlashcardWithDeck>(),
        );

      default:
        throw UnsupportedError(
          'Unsupported Flashcards resource: '
              '${resource.resourceType}',
        );
    }
  }

  ShareResource _deck(
      FlashcardDeck deck,
      ) {
    return ShareResource(
      resourceType: ShareResourceType.flashcardDeck,
      resourceVersion: 1,
      resourceId: deck.id,
      metadata: ShareResourceMetadata(
        displayName: deck.name,
        createdAt: deck.createdAt,
        updatedAt: deck.updatedAt,
        tags: deck.tags,
      ),
      payload: {
        'tags': deck.tags,
        'generationMethod': deck.generationMethod.name,
        'sourceReference': deck.sourceReference,
        'description': deck.description,
      },
    );
  }

  ShareResource _card(
      FlashcardWithDeck wrapper,
      ) {
    final card = wrapper.card;

    return ShareResource(
      resourceType: ShareResourceType.flashcard,
      resourceVersion: 1,
      resourceId: card.id,
      metadata: ShareResourceMetadata(
        displayName: card.front,
        createdAt: card.createdAt,
        updatedAt: card.updatedAt,
        tags: card.tags,
      ),
      payload: {
        'deckId': wrapper.deckId,
        'front': card.front,
        'back': card.back,
        'tags': card.tags,
        'frontImageUrl': card.frontImageUrl,
        'backImageUrl': card.backImageUrl,
      },
    );
  }
}
