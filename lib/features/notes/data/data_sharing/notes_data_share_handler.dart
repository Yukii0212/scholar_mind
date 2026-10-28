import 'package:firebase_storage/firebase_storage.dart';

import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../../data_sharing/domain/models/validation/validation_result.dart';
import '../../../data_sharing/registry/data_share_handler.dart';
import '../../../data_sharing/services/hierarchical_import_planner.dart';
import '../../../data_sharing/services/share_download_limits.dart';
import '../../../data_sharing/services/share_resource_validator.dart';
import '../../domain/library_folder.dart';
import '../../domain/note_category.dart';
import '../repository/library_repository.dart';
import 'notes_collection_service.dart';
import 'notes_export_mapper.dart';
import 'notes_import_mapper.dart';

class NotesDataShareHandler implements DataShareHandler {
  NotesDataShareHandler({
    required NotesCollectionService collector,
    required LibraryRepository repository,
    NotesExportMapper? exportMapper,
    NotesImportMapper? importMapper,
  })  : _collector = collector,
        _repository = repository,
        _exportMapper = exportMapper ?? const NotesExportMapper(),
        _importMapper = importMapper ?? const NotesImportMapper();

  final NotesCollectionService _collector;

  final LibraryRepository _repository;

  final NotesExportMapper _exportMapper;

  final NotesImportMapper _importMapper;

  @override
  List<ShareResourceType> get resourceTypes => const [
        ShareResourceType.note,
        ShareResourceType.noteFolder,
      ];

  @override
  ValidationResult validateExport(
    List<String> resourceIds,
  ) {
    if (resourceIds.isEmpty) {
      return const ValidationResult(
        isValid: false,
        errors: [
          'No notes selected.',
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
      case ShareResourceType.noteFolder:
        validator.requireString('parentId');
        validator.optionalBool('isFavorite');
        break;
      case ShareResourceType.note:
        validator.requireString('folderId');
        validator.requireInt('sizeBytes', minimum: 0);
        validator.requireString('category');
        validator.requireString('source');
        final isInternal = validator.requireBool('isInternal');
        validator.optionalBool('isFavorite');

        if (isInternal == true) {
          validator.requireString('content', allowEmpty: true);
          validator.optionalString('fileStoragePath');
        } else if (isInternal == false) {
          validator.requireString('extension');
          validator.requireString('fileStoragePath');
          validator.optionalString('content');
        }

        final category = resource.payload['category'];

        if (category is String &&
            !NoteCategory.values.any((value) => value.key == category)) {
          validator.addError('unknown note category "$category".');
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
          (resource) => resource.resourceType == ShareResourceType.noteFolder,
        )
        .toList();
    final folderIds = folders.map((resource) => resource.resourceId).toSet();
    final warnings = <String>[];

    try {
      final plan = planHierarchicalImport(
        items: folders,
        idOf: (resource) => resource.resourceId,
        parentIdOf: (resource) => resource.payload['parentId'] as String,
        isRootParent: (parentId) => parentId == LibraryFolder.rootId,
        resourceLabel: 'note folder',
      );

      if (plan.detachedIds.isNotEmpty) {
        warnings.add(
          'Some note folders have no selected parent and will be imported '
          'at the root level.',
        );
      }
    } on FormatException catch (error) {
      return ValidationResult(
        isValid: false,
        errors: [error.message.toString()],
      );
    }

    final hasDetachedNotes = resources.any((resource) {
      if (resource.resourceType != ShareResourceType.note) {
        return false;
      }

      final folderId = resource.payload['folderId'] as String;
      return folderId != LibraryFolder.rootId && !folderIds.contains(folderId);
    });

    if (hasDetachedNotes) {
      warnings.add(
        'Some notes have no selected folder and will be imported at the '
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
    onProgress?.call('Collecting notes and folders...');

    final collected = await _collector.collect(
      userId: userId,
      resourceIds: resourceIds,
    );
    ensureSessionCurrent?.call();

    for (final resource in collected.resources) {
      (
        '${resource.resourceType.name} '
            '${resource.resourceId} '
            '${resource.data.runtimeType}',
      );
    }

    // Each note with a file is now copied to its own object under this
    // share (see NotesExportMapper._note), one at a time per mapper call,
    // rather than every file's full bytes ending up embedded together in
    // one archive blob. Still bounded to a handful in flight at once so a
    // folder with many files doesn't fire dozens of concurrent
    // download+upload pairs simultaneously.
    final total = collected.resources.length;

    final resources = await _mapInBatches(
      collected.resources,
      (resource) async {
        ensureSessionCurrent?.call();
        final mapped = await _exportMapper.toResource(
          resource,
          userId: userId,
          shareId: shareId,
        );
        ensureSessionCurrent?.call();
        return mapped;
      },
      batchSize: 4,
      onBatchComplete: (done) =>
          onProgress?.call('Copied $done of $total items'),
    );

    for (final resource in resources) {
      (
        '${resource.resourceType.name} '
            '${resource.metadata.displayName}',
      );
    }

    return resources;
  }

  @override
  Future<void> import({
    required String userId,
    required List<ShareResource> resources,
    void Function()? ensureSessionCurrent,
  }) async {
    ensureSessionCurrent?.call();
    ('=== Notes import started ===');
    ('Resources: ${resources.length}');

    if (resources.isEmpty) {
      return;
    }

    final folderMap = <String, String>{};

    final folders = resources
        .where(
          (resource) => resource.resourceType == ShareResourceType.noteFolder,
        )
        .toList();

    final notes = resources
        .where(
          (resource) => resource.resourceType == ShareResourceType.note,
        )
        .toList();

    ('Folders: ${folders.length}, Notes: ${notes.length}',);

    if (folders.isEmpty && notes.isEmpty) {
      return;
    }

    final folderPlan = planHierarchicalImport(
      items: folders,
      idOf: (resource) => resource.resourceId,
      parentIdOf: (resource) => resource.payload['parentId'] as String,
      isRootParent: (parentId) => parentId == LibraryFolder.rootId,
      resourceLabel: 'note folder',
    );

    for (final resource in folderPlan.orderedItems) {
      ensureSessionCurrent?.call();
      final payload = _importMapper.folderPayload(resource);
      final oldParentId = payload['parentId'] as String;
      final targetParentId = oldParentId == LibraryFolder.rootId ||
              folderPlan.detachedIds.contains(resource.resourceId)
          ? LibraryFolder.rootId
          : folderMap[oldParentId]!;
      final newFolderId = await _repository.importFolder(
        userId: userId,
        name: resource.metadata.displayName,
        parentId: targetParentId,
        isFavorite: payload['isFavorite'] as bool? ?? false,
      );
      ensureSessionCurrent?.call();

      folderMap[resource.resourceId] = newFolderId;
    }

    for (final resource in notes) {
      ensureSessionCurrent?.call();
      final payload = _importMapper.notePayload(resource);

      final originalFolderId = payload['folderId'] as String;

      final targetFolderId = originalFolderId == LibraryFolder.rootId
          ? LibraryFolder.rootId
          : folderMap[originalFolderId] ?? LibraryFolder.rootId;

      final isInternal = payload['isInternal'] as bool? ?? false;

      try {
        if (isInternal) {
          await _collector.repository.importInternalNote(
            userId: userId,
            folderId: targetFolderId,
            name: resource.metadata.displayName,
            content: payload['content'] as String? ?? '',
            category: payload['category'] as String,
            isFavorite: payload['isFavorite'] as bool? ?? false,
          );
          ensureSessionCurrent?.call();
        } else {
          final fileStoragePath = payload['fileStoragePath'] as String?;

          if (fileStoragePath == null) {
            continue;
          }

          final fileBytes = await FirebaseStorage.instance
              .ref(fileStoragePath)
              .getData(maxShareObjectDownloadBytes);

          ensureSessionCurrent?.call();

          if (fileBytes == null) {
            throw StateError(
              'Shared file for note "${resource.metadata.displayName}" '
              'could not be downloaded.',
            );
          }

          await _collector.repository.importUploadedNote(
            userId: userId,
            folderId: targetFolderId,
            name: resource.metadata.displayName,
            extension: payload['extension'] as String,
            fileBytes: fileBytes,
            category: payload['category'] as String,
            source: payload['source'] as String,
            isFavorite: payload['isFavorite'] as bool? ?? false,
          );
          ensureSessionCurrent?.call();
        }
      } catch (_) {
        rethrow;
      }
    }
  }
}

/// Applies [mapper] to [items] [batchSize] at a time, waiting for each
/// batch to finish before starting the next — unlike a single unbounded
/// `Future.wait(items.map(mapper))`, this keeps at most [batchSize]
/// mapper calls (and whatever memory each one holds, e.g. downloaded file
/// bytes) in flight simultaneously.
Future<List<R>> _mapInBatches<T, R>(
  List<T> items,
  Future<R> Function(T) mapper, {
  required int batchSize,
  void Function(int done)? onBatchComplete,
}) async {
  final results = <R>[];

  for (var i = 0; i < items.length; i += batchSize) {
    final batch = items.skip(i).take(batchSize);
    results.addAll(await Future.wait(batch.map(mapper)));
    onBatchComplete?.call(results.length);
  }

  return results;
}
