import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../../data_sharing/domain/models/validation/validation_result.dart';
import '../../../data_sharing/registry/data_share_handler.dart';
import '../../domain/flashcard_models.dart';
import '../flashcard_repository.dart';
import 'flashcard_collection_service.dart';
import 'flashcard_export_mapper.dart';
import 'flashcard_import_mapper.dart';

class FlashcardDataShareHandler
    implements DataShareHandler {
  FlashcardDataShareHandler({
    required FlashcardCollectionService collector,
    required FlashcardRepository repository,
    FlashcardExportMapper? exportMapper,
    FlashcardImportMapper? importMapper,
  })  : _collector = collector,
        _repository = repository,
        _exportMapper =
            exportMapper ?? const FlashcardExportMapper(),
        _importMapper =
            importMapper ?? const FlashcardImportMapper();

  final FlashcardCollectionService _collector;

  final FlashcardRepository _repository;

  final FlashcardExportMapper _exportMapper;

  final FlashcardImportMapper _importMapper;

  @override
  List<ShareResourceType> get resourceTypes => const [
    ShareResourceType.flashcardDeck,
    ShareResourceType.flashcard,
  ];

  @override
  ValidationResult validateExport(
      List<String> resourceIds,
      ) {
    if (resourceIds.isEmpty) {
      return const ValidationResult(
        isValid: false,
        errors: [
          'No flashcard decks selected.',
        ],
      );
    }

    return const ValidationResult(
      isValid: true,
    );
  }

  @override
  ValidationResult validateImport(
      ShareResource resource,
      ) {
    return const ValidationResult(
      isValid: true,
    );
  }

  @override
  Future<List<ShareResource>> export({
    required String userId,
    required List<String> resourceIds,
    required String shareId,
  }) async {
    final collected = await _collector.collect(
      userId: userId,
      resourceIds: resourceIds,
    );

    return collected.resources
        .map(_exportMapper.toResource)
        .toList();
  }

  @override
  Future<void> import({
    required String userId,
    required List<ShareResource> resources,
  }) async {
    if (resources.isEmpty) {
      return;
    }

    final deckIdMap = <String, String>{};

    final decks = resources
        .where(
          (resource) =>
      resource.resourceType ==
          ShareResourceType.flashcardDeck,
    )
        .toList();

    final cards = resources
        .where(
          (resource) =>
      resource.resourceType ==
          ShareResourceType.flashcard,
    )
        .toList();

    for (final resource in decks) {
      final payload = _importMapper.deckPayload(resource);

      final newDeckId = await _repository.saveDeck(
        userId: userId,
        name: resource.metadata.displayName,
        tags: (payload['tags'] as List<dynamic>?)
            ?.cast<String>() ??
            const [],
        generationMethod: FlashcardGenerationMethod.fromJson(
          payload['generationMethod'] as String?,
        ),
        sourceReference: payload['sourceReference'] as String?,
        description: payload['description'] as String?,
      );

      deckIdMap[resource.resourceId] = newDeckId;
    }

    for (final resource in cards) {
      final payload = _importMapper.cardPayload(resource);

      final newDeckId = deckIdMap[payload['deckId'] as String?];

      if (newDeckId == null) {
        continue;
      }

      await _repository.saveCard(
        userId: userId,
        deckId: newDeckId,
        front: payload['front'] as String? ?? '',
        back: payload['back'] as String? ?? '',
        tags: (payload['tags'] as List<dynamic>?)
            ?.cast<String>() ??
            const [],
        frontImageUrl: payload['frontImageUrl'] as String?,
        backImageUrl: payload['backImageUrl'] as String?,
      );
    }
  }
}
