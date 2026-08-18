import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_metadata.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../domain/flashcard_models.dart';
import 'flashcard_with_set.dart';

class FlashcardExportMapper {
  const FlashcardExportMapper();

  ShareResource toResource(
      CollectedResource resource,
      ) {
    switch (resource.resourceType) {
      case ShareResourceType.flashcardSet:
        return _set(
          resource.asType<FlashcardSet>(),
        );

      case ShareResourceType.flashcard:
        return _card(
          resource.asType<FlashcardWithSet>(),
        );

      default:
        throw UnsupportedError(
          'Unsupported Flashcards resource: '
              '${resource.resourceType}',
        );
    }
  }

  ShareResource _set(
      FlashcardSet flashcardSet,
      ) {
    return ShareResource(
      resourceType: ShareResourceType.flashcardSet,
      resourceVersion: 1,
      resourceId: flashcardSet.id,
      metadata: ShareResourceMetadata(
        displayName: flashcardSet.name,
        createdAt: flashcardSet.createdAt,
        updatedAt: flashcardSet.updatedAt,
        tags: flashcardSet.tags,
      ),
      payload: {
        'tags': flashcardSet.tags,
        'generationMethod': flashcardSet.generationMethod.name,
        'sourceReference': flashcardSet.sourceReference,
        'description': flashcardSet.description,
      },
    );
  }

  ShareResource _card(
      FlashcardWithSet wrapper,
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
        'setId': wrapper.setId,
        'front': card.front,
        'back': card.back,
        'tags': card.tags,
        'frontImageUrl': card.frontImageUrl,
        'backImageUrl': card.backImageUrl,
      },
    );
  }
}
