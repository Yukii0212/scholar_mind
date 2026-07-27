import '../../../data_sharing/domain/models/share/share_resource.dart';

class QuizImportMapper {
  const QuizImportMapper();

  Map<String, dynamic> folderPayload(
      ShareResource resource,
      ) {
    return resource.payload;
  }

  Map<String, dynamic> quizPayload(
      ShareResource resource,
      ) {
    return resource.payload;
  }
}
