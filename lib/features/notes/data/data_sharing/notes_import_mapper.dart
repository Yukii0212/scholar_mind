import '../../../data_sharing/domain/models/share/share_resource.dart';

class NotesImportMapper {
  const NotesImportMapper();

  Map<String, dynamic> folderPayload(
      ShareResource resource,
      ) {
    return resource.payload;
  }

  Map<String, dynamic> notePayload(
      ShareResource resource,
      ) {
    return resource.payload;
  }
}