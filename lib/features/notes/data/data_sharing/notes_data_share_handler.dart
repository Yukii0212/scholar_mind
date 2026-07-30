import 'package:firebase_storage/firebase_storage.dart';
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
    required String shareId,
  }) async {
    final collected =
    await _collector.collect(
      userId: userId,
      resourceIds: resourceIds,
    );

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
    final resources = await _mapInBatches(
      collected.resources,
      (resource) => _exportMapper.toResource(
        resource,
        userId: userId,
        shareId: shareId,
      ),
      batchSize: 4,
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

        folderMap[resource.resourceId] =
            newFolderId;

        importedAny = true;
      }
    }

    for (final resource in notes) {
      final payload =
      _importMapper.notePayload(resource);

      final originalFolderId = payload['folderId'] as String;

      final targetFolderId =
      originalFolderId == LibraryFolder.rootId
          ? LibraryFolder.rootId
          : folderMap[originalFolderId] ?? LibraryFolder.rootId;

      final isInternal =
          payload['isInternal'] as bool? ?? false;

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
        } else {
          final fileStoragePath = payload['fileStoragePath'] as String?;

          if (fileStoragePath == null) {
            continue;
          }

          final fileBytes = await FirebaseStorage.instance
              .ref(fileStoragePath)
              .getData();

          if (fileBytes == null) {
            continue;
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
        }
      } catch (e, st) {
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
}) async {
  final results = <R>[];

  for (var i = 0; i < items.length; i += batchSize) {
    final batch = items.skip(i).take(batchSize);
    results.addAll(await Future.wait(batch.map(mapper)));
  }

  return results;
}