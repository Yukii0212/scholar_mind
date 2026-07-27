import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_metadata.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../domain/quiz_attempt.dart';
import '../../domain/quiz_folder.dart';

class QuizExportMapper {
  const QuizExportMapper();

  ShareResource toResource(
      CollectedResource resource,
      ) {
    switch (resource.resourceType) {
      case ShareResourceType.quiz:
        return _quiz(
          resource.asType<QuizAttempt>(),
        );

      case ShareResourceType.quizFolder:
        return _folder(
          resource.asType<QuizFolder>(),
        );

      default:
        throw UnsupportedError(
          'Unsupported Quiz resource: '
              '${resource.resourceType}',
        );
    }
  }

  ShareResource _folder(
      QuizFolder folder,
      ) {
    return ShareResource(
      resourceType: ShareResourceType.quizFolder,
      resourceVersion: 1,
      resourceId: folder.id,
      metadata: ShareResourceMetadata(
        displayName: folder.name,
        createdAt: folder.createdAt,
        updatedAt: folder.updatedAt,
      ),
      payload: {
        'parentId': folder.parentId,
        'isFavorite': folder.isFavorite,
      },
    );
  }

  ShareResource _quiz(
      QuizAttempt attempt,
      ) {
    return ShareResource(
      resourceType: ShareResourceType.quiz,
      resourceVersion: 1,
      resourceId: attempt.id,
      metadata: ShareResourceMetadata(
        displayName: attempt.name,
        createdAt: attempt.createdAt,
        updatedAt: attempt.updatedAt,
      ),
      payload: {
        'folderId': attempt.folderId,
        'isFavorite': attempt.isFavorite,
        'quiz': attempt.quiz.toJson(),
      },
    );
  }
}
