import '../../../data_sharing/domain/models/share/share_resource.dart';

class FlashcardImportMapper {
  const FlashcardImportMapper();

  Map<String, dynamic> deckPayload(
      ShareResource resource,
      ) {
    return resource.payload;
  }

  Map<String, dynamic> cardPayload(
      ShareResource resource,
      ) {
    return resource.payload;
  }
}
