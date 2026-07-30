import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../../data_sharing/domain/models/validation/validation_result.dart';
import '../../../data_sharing/registry/data_share_handler.dart';
import '../../domain/quiz_folder.dart';
import '../../domain/quiz_response.dart';
import '../quiz_library_repository.dart';
import 'quiz_collection_service.dart';
import 'quiz_export_mapper.dart';
import 'quiz_import_mapper.dart';

class QuizDataShareHandler
    implements DataShareHandler {
  QuizDataShareHandler({
    required QuizCollectionService collector,
    required QuizLibraryRepository repository,
    QuizExportMapper? exportMapper,
    QuizImportMapper? importMapper,
  })  : _collector = collector,
        _repository = repository,
        _exportMapper =
            exportMapper ?? const QuizExportMapper(),
        _importMapper =
            importMapper ?? const QuizImportMapper();

  final QuizCollectionService _collector;

  final QuizLibraryRepository _repository;

  final QuizExportMapper _exportMapper;

  final QuizImportMapper _importMapper;

  @override
  List<ShareResourceType> get resourceTypes => const [
    ShareResourceType.quiz,
    ShareResourceType.quizFolder,
  ];

  @override
  ValidationResult validateExport(
      List<String> resourceIds,
      ) {
    if (resourceIds.isEmpty) {
      return const ValidationResult(
        isValid: false,
        errors: [
          'No quizzes selected.',
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

    final folderMap = <String, String>{};

    final folders = resources
        .where(
          (resource) =>
      resource.resourceType ==
          ShareResourceType.quizFolder,
    )
        .toList();

    final quizzes = resources
        .where(
          (resource) =>
      resource.resourceType ==
          ShareResourceType.quiz,
    )
        .toList();

    if (folders.isEmpty && quizzes.isEmpty) {
      return;
    }

    while (folderMap.length < folders.length) {
      for (final resource in folders) {
        if (folderMap.containsKey(resource.resourceId)) {
          continue;
        }

        final payload =
        _importMapper.folderPayload(resource);

        final oldParentId =
        payload['parentId'] as String;

        final canImport =
            oldParentId == QuizFolder.rootId ||
                folderMap.containsKey(oldParentId);

        if (!canImport) {
          continue;
        }

        final newFolderId =
        await _repository.createFolder(
          userId: userId,
          parentId: oldParentId == QuizFolder.rootId
              ? QuizFolder.rootId
              : folderMap[oldParentId]!,
          name: resource.metadata.displayName,
        );

        folderMap[resource.resourceId] =
            newFolderId;
      }
    }

    for (final resource in quizzes) {
      final payload = _importMapper.quizPayload(resource);

      final originalFolderId = payload['folderId'] as String;

      final targetFolderId =
      originalFolderId == QuizFolder.rootId
          ? QuizFolder.rootId
          : folderMap[originalFolderId] ?? QuizFolder.rootId;

      await _repository.importQuiz(
        userId: userId,
        folderId: targetFolderId,
        name: resource.metadata.displayName,
        quiz: QuizResponse.fromJson(
          Map<String, dynamic>.from(
            payload['quiz'] as Map,
          ),
        ),
      );
    }
  }
}
