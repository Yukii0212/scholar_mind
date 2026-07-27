import '../../../data_sharing/domain/models/share/share_resource.dart';

class GradesImportMapper {
  const GradesImportMapper();

  Map<String, dynamic> payloadOf(
      ShareResource resource,
      ) {
    return resource.payload;
  }
}
