import '../../../data_sharing/domain/models/share/share_resource.dart';

class FlashcardImportMapper {
  const FlashcardImportMapper();

  Map<String, dynamic> setPayload(
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
