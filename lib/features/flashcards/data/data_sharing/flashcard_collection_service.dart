import '../../../data_sharing/collection/data_share_collector.dart';
import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/collection/collection_result.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../flashcard_repository.dart';
import 'flashcard_with_set.dart';

class FlashcardCollectionService implements DataShareCollector {
  FlashcardCollectionService({
    required this.repository,
  });

  final FlashcardRepository repository;

  @override
  ShareResourceType get resourceType => ShareResourceType.flashcardSet;

  @override
  Future<CollectionResult> collect({
    required String userId,
    required List<String> resourceIds,
  }) async {
    final resources = <CollectedResource>[];
    final visitedSets = <String>{};

    for (final setId in resourceIds) {
      if (!visitedSets.add(setId)) {
        continue;
      }

      final flashcardSet = await repository.getSet(
        userId: userId,
        setId: setId,
      );

      if (flashcardSet == null) {
        continue;
      }

      resources.add(
        CollectedResource(
          resourceType: ShareResourceType.flashcardSet,
          resourceId: flashcardSet.id,
          data: flashcardSet,
        ),
      );

      final cards = await repository.getCardsInSet(
        userId: userId,
        setId: flashcardSet.id,
      );

      for (final card in cards) {
        resources.add(
          CollectedResource(
            resourceType: ShareResourceType.flashcard,
            resourceId: card.id,
            data: FlashcardWithSet(
              card: card,
              setId: flashcardSet.id,
            ),
          ),
        );
      }
    }

    return CollectionResult(resources: resources);
  }
}
