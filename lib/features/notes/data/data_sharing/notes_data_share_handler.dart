
import 'package:flutter/cupertino.dart';

import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../../data_sharing/domain/models/validation/validation_result.dart';
import '../../../data_sharing/registry/data_share_handler.dart';
import '../../domain/library_folder.dart';
import '../../domain/note_item.dart';
import '../repository/library_repository.dart';
import 'notes_collection_service.dart';
import 'notes_export_mapper.dart';
import 'notes_import_mapper.dart';

class NotesDataShareHandler
    implements DataShareHandler {
  NotesDataShareHandler({
    required NotesCollectionService collector,
    required LibraryRepository repository,
    NotesExportMapper? exportMapper,
    NotesImportMapper? importMapper,
  })  : _collector = collector,
        _repository = repository,
        _exportMapper =
            exportMapper ?? const NotesExportMapper(),
        _importMapper =
            importMapper ?? const NotesImportMapper();

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
    return const ValidationResult(
      isValid: true,
    );
  }

  @override
  Future<List<ShareResource>> export({
    required String userId,
    required List<String> resourceIds,
  }) async {
    final collected =
    await _collector.collect(
      userId: userId,
      resourceIds: resourceIds,
    );

    ('=== Collected Resources ===');

    for (final resource in collected.resources) {
      (
        '${resource.resourceType.name} '
            '${resource.resourceId} '
            '${resource.data.runtimeType}',
      );
    }

    final resources = collected.resources
        .map(_exportMapper.toResource)
        .toList();

    ('=== Share Resources ===');

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
  })async {
    ('=== Notes import started ===');
    ('Resources: ${resources.length}');

    if (resources.isEmpty) {
      return;
    }

    final folderMap = <String, String>{};

    final folders = resources
        .where(
          (resource) =>
      resource.resourceType ==
          ShareResourceType.noteFolder,
    )
        .toList();

    final notes = resources
        .where(
          (resource) =>
      resource.resourceType ==
          ShareResourceType.note,
    )
        .toList();

    (
      'Folders: ${folders.length}, Notes: ${notes.length}',
    );

    if (folders.isEmpty && notes.isEmpty) {
      return;
    }

    while (folderMap.length < folders.length) {
      var importedAny = false;

      for (final resource in folders) {
        if (folderMap.containsKey(resource.resourceId)) {
          continue;
        }

        final payload =
        _importMapper.folderPayload(resource);

        debugPrint('----- Folder Payload -----');
        debugPrint('id=${resource.resourceId}');
        debugPrint('name=${resource.metadata.displayName}');
        debugPrint(payload.toString());

        final oldParentId =
        payload['parentId'] as String;

        final canImport =
            oldParentId == LibraryFolder.rootId ||
                folderMap.containsKey(oldParentId);

        if (!canImport) {
          continue;
        }

        (
          'Importing folder: ${resource.metadata.displayName}',
        );

        final newFolderId =
        await _repository.importFolder(
          userId: userId,
          name: resource.metadata.displayName,
          parentId: oldParentId == LibraryFolder.rootId
              ? LibraryFolder.rootId
              : folderMap[oldParentId]!,
          isFavorite:
          payload['isFavorite'] as bool? ?? false,
        );

        (
          'Created folder: $newFolderId',
        );

        folderMap[resource.resourceId] =
            newFolderId;

        importedAny = true;
      }

      if (!importedAny) {
        (
          'Unable to resolve remaining folder hierarchy.',
        );
        break;
      }
    }

    for (final resource in notes) {
      final payload =
      _importMapper.notePayload(resource);

      debugPrint('----- Note Payload -----');
      debugPrint('id=${resource.resourceId}');
      debugPrint('name=${resource.metadata.displayName}');
      debugPrint(payload.toString());

      final originalFolderId = payload['folderId'] as String;

      final targetFolderId =
      originalFolderId == LibraryFolder.rootId
          ? LibraryFolder.rootId
          : folderMap[originalFolderId] ?? LibraryFolder.rootId;

      if (targetFolderId == null) {
        (
          'Skipping note "${resource.metadata.displayName}" because folder "$originalFolderId" was not imported.',
        );
        continue;
      }

      (
        'Importing note: ${resource.metadata.displayName}',
      );

      final isInternal =
          payload['isInternal'] as bool? ?? false;

      try {
        if (isInternal) {
          debugPrint('===== IMPORTING INTERNAL NOTE =====');
          debugPrint('folderId=$targetFolderId');
          debugPrint('payload=$payload');

          await _collector.repository.importInternalNote(
            userId: userId,
            folderId: targetFolderId,
            name: resource.metadata.displayName,
            content: payload['content'] as String? ?? '',
            category: payload['category'] as String,
            isFavorite: payload['isFavorite'] as bool? ?? false,
          );
        } else {
          debugPrint('===== IMPORTING UPLOADED NOTE =====');
          debugPrint('folderId=$targetFolderId');
          debugPrint('payload=$payload');

          await _collector.repository.importUploadedNote(
            userId: userId,
            folderId: targetFolderId,
            name: resource.metadata.displayName,
            extension: payload['extension'] as String,
            storagePath: payload['storagePath'] as String,
            sizeBytes: payload['sizeBytes'] as int,
            category: payload['category'] as String,
            source: payload['source'] as String,
            isFavorite: payload['isFavorite'] as bool? ?? false,
          );
        }
      } catch (e, st) {
        debugPrint('========== IMPORT FAILED ==========');
        debugPrint('Resource: ${resource.metadata.displayName}');
        debugPrint('Type: ${resource.resourceType}');
        debugPrint('Payload: $payload');
        debugPrint('Error: $e');
        debugPrint(st.toString());
        rethrow;
      }
    }
  }
}