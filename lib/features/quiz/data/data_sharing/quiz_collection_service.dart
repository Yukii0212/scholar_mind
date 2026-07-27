import '../../../data_sharing/collection/data_share_collector.dart';
import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/collection/collection_result.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../quiz_library_repository.dart';

class QuizCollectionService
    implements DataShareCollector {
  QuizCollectionService({
    required this.repository,
  });

  final QuizLibraryRepository repository;

  @override
  ShareResourceType get resourceType => ShareResourceType.quiz;

  @override
  Future<CollectionResult> collect({
    required String userId,
    required List<String> resourceIds,
  }) async {
    final resources = <CollectedResource>[];
    final visitedFolders = <String>{};
    final visitedQuizzes = <String>{};

    for (final resourceId in resourceIds) {
      await _collectResource(
        userId: userId,
        resourceId: resourceId,
        resources: resources,
        visitedFolders: visitedFolders,
        visitedQuizzes: visitedQuizzes,
      );
    }

    return CollectionResult(resources: resources);
  }

  Future<void> _collectResource({
    required String userId,
    required String resourceId,
    required List<CollectedResource> resources,
    required Set<String> visitedFolders,
    required Set<String> visitedQuizzes,
  }) async {
    final folder = await repository.getFolder(
      userId: userId,
      folderId: resourceId,
    );

    if (folder != null) {
      await _collectFolder(
        userId: userId,
        folderId: folder.id,
        resources: resources,
        visitedFolders: visitedFolders,
        visitedQuizzes: visitedQuizzes,
      );
      return;
    }

    final quiz = await repository.getQuiz(
      userId: userId,
      quizId: resourceId,
    );

    if (quiz == null || !visitedQuizzes.add(quiz.id)) {
      return;
    }

    resources.add(
      CollectedResource(
        resourceType: ShareResourceType.quiz,
        resourceId: quiz.id,
        data: quiz,
      ),
    );
  }

  Future<void> _collectFolder({
    required String userId,
    required String folderId,
    required List<CollectedResource> resources,
    required Set<String> visitedFolders,
    required Set<String> visitedQuizzes,
  }) async {
    if (!visitedFolders.add(folderId)) {
      return;
    }

    final folder = await repository.getFolder(
      userId: userId,
      folderId: folderId,
    );

    if (folder == null) {
      return;
    }

    resources.add(
      CollectedResource(
        resourceType: ShareResourceType.quizFolder,
        resourceId: folder.id,
        data: folder,
      ),
    );

    final quizzes = await repository.getQuizzesInFolder(
      userId: userId,
      folderId: folder.id,
    );

    for (final quiz in quizzes) {
      if (!visitedQuizzes.add(quiz.id)) {
        continue;
      }

      resources.add(
        CollectedResource(
          resourceType: ShareResourceType.quiz,
          resourceId: quiz.id,
          data: quiz,
        ),
      );
    }

    final childFolders = await repository.getChildFolders(
      userId: userId,
      parentFolderId: folder.id,
    );

    for (final child in childFolders) {
      await _collectFolder(
        userId: userId,
        folderId: child.id,
        resources: resources,
        visitedFolders: visitedFolders,
        visitedQuizzes: visitedQuizzes,
      );
    }
  }
}
