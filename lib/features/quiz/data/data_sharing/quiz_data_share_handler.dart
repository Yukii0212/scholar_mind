import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../../data_sharing/domain/models/validation/validation_result.dart';
import '../../../data_sharing/registry/data_share_handler.dart';
import '../../../data_sharing/services/hierarchical_import_planner.dart';
import '../../../data_sharing/services/share_resource_validator.dart';
import '../../domain/quiz_folder.dart';
import '../../domain/quiz_response.dart';
import '../quiz_library_repository.dart';
import 'quiz_collection_service.dart';
import 'quiz_export_mapper.dart';
import 'quiz_import_mapper.dart';

class QuizDataShareHandler implements DataShareHandler {
  QuizDataShareHandler({
    required QuizCollectionService collector,
    required QuizLibraryRepository repository,
    QuizExportMapper? exportMapper,
    QuizImportMapper? importMapper,
  })  : _collector = collector,
        _repository = repository,
        _exportMapper = exportMapper ?? const QuizExportMapper(),
        _importMapper = importMapper ?? const QuizImportMapper();

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
    final validator = ShareResourceValidator(
      resource,
      supportedTypes: resourceTypes.toSet(),
    );

    switch (resource.resourceType) {
      case ShareResourceType.quizFolder:
        validator.requireString('parentId');
        validator.optionalBool('isFavorite');
        break;
      case ShareResourceType.quiz:
        validator.requireString('folderId');
        validator.optionalBool('isFavorite');
        final quiz = validator.requireMap('quiz');

        if (quiz != null) {
          try {
            QuizResponse.fromJson(quiz);
          } catch (error) {
            validator.addError('quiz payload is invalid: $error');
          }
        }
        break;
      default:
        break;
    }

    return validator.result();
  }

  @override
  ValidationResult validateImportBatch(List<ShareResource> resources) {
    final folders = resources
        .where(
          (resource) => resource.resourceType == ShareResourceType.quizFolder,
        )
        .toList();
    final folderIds = folders.map((resource) => resource.resourceId).toSet();
    final warnings = <String>[];

    try {
      final plan = planHierarchicalImport(
        items: folders,
        idOf: (resource) => resource.resourceId,
        parentIdOf: (resource) => resource.payload['parentId'] as String,
        isRootParent: (parentId) => parentId == QuizFolder.rootId,
        resourceLabel: 'quiz folder',
      );

      if (plan.detachedIds.isNotEmpty) {
        warnings.add(
          'Some quiz folders have no selected parent and will be imported '
          'at the root level.',
        );
      }
    } on FormatException catch (error) {
      return ValidationResult(
        isValid: false,
        errors: [error.message.toString()],
      );
    }

    final hasDetachedQuizzes = resources.any((resource) {
      if (resource.resourceType != ShareResourceType.quiz) {
        return false;
      }

      final folderId = resource.payload['folderId'] as String;
      return folderId != QuizFolder.rootId && !folderIds.contains(folderId);
    });

    if (hasDetachedQuizzes) {
      warnings.add(
        'Some quizzes have no selected folder and will be imported at the '
        'root level.',
      );
    }

    return ValidationResult(
      isValid: true,
      warnings: warnings,
    );
  }

  @override
  Future<List<ShareResource>> export({
    required String userId,
    required List<String> resourceIds,
    required String shareId,
    void Function(String message)? onProgress,
    void Function()? ensureSessionCurrent,
  }) async {
    ensureSessionCurrent?.call();
    final collected = await _collector.collect(
      userId: userId,
      resourceIds: resourceIds,
    );
    ensureSessionCurrent?.call();

    return collected.resources.map(_exportMapper.toResource).toList();
  }

  @override
  Future<void> import({
    required String userId,
    required List<ShareResource> resources,
    void Function()? ensureSessionCurrent,
  }) async {
    ensureSessionCurrent?.call();
    if (resources.isEmpty) {
      return;
    }

    final folderMap = <String, String>{};

    final folders = resources
        .where(
          (resource) => resource.resourceType == ShareResourceType.quizFolder,
        )
        .toList();

    final quizzes = resources
        .where(
          (resource) => resource.resourceType == ShareResourceType.quiz,
        )
        .toList();

    if (folders.isEmpty && quizzes.isEmpty) {
      return;
    }

    final folderPlan = planHierarchicalImport(
      items: folders,
      idOf: (resource) => resource.resourceId,
      parentIdOf: (resource) => resource.payload['parentId'] as String,
      isRootParent: (parentId) => parentId == QuizFolder.rootId,
      resourceLabel: 'quiz folder',
    );

    for (final resource in folderPlan.orderedItems) {
      ensureSessionCurrent?.call();
      final payload = _importMapper.folderPayload(resource);
      final oldParentId = payload['parentId'] as String;
      final targetParentId = oldParentId == QuizFolder.rootId ||
              folderPlan.detachedIds.contains(resource.resourceId)
          ? QuizFolder.rootId
          : folderMap[oldParentId]!;
      final newFolderId = await _repository.createFolder(
        userId: userId,
        parentId: targetParentId,
        name: resource.metadata.displayName,
      );
      ensureSessionCurrent?.call();

      folderMap[resource.resourceId] = newFolderId;
    }

    for (final resource in quizzes) {
      ensureSessionCurrent?.call();
      final payload = _importMapper.quizPayload(resource);

      final originalFolderId = payload['folderId'] as String;

      final targetFolderId = originalFolderId == QuizFolder.rootId
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
      ensureSessionCurrent?.call();
    }
  }
}
