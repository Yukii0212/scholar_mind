import '../../../data_sharing/collection/data_share_collector.dart';
import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/collection/collection_result.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../library_repository.dart';

class NotesCollectionService
    implements DataShareCollector {
  NotesCollectionService({
    required LibraryRepository repository,
  }) : _repository = repository;

  final LibraryRepository _repository;

  @override
  ShareResourceType get resourceType =>
      ShareResourceType.note;

  @override
  Future<CollectionResult> collect({
    required String userId,
    required List<String> resourceIds,
  }) async {
    final resources = <CollectedResource>[];

    for (final resourceId in resourceIds) {
      final folder = await _repository.getFolder(
        userId: userId,
        folderId: resourceId,
      );

      if (folder != null) {
        resources.add(
          CollectedResource(
            resourceType: ShareResourceType.noteFolder,
            resourceId: folder.id,
            data: folder,
          ),
        );

        final notes = await _repository.getNotesInFolder(
          userId: userId,
          folderId: folder.id,
        );

        for (final note in notes) {
          resources.add(
            CollectedResource(
              resourceType: ShareResourceType.note,
              resourceId: note.id,
              data: note,
            ),
          );
        }

        final childFolders =
        await _repository.getChildFolders(
          userId: userId,
          parentFolderId: folder.id,
        );

        for (final childFolder in childFolders) {
          resources.add(
            CollectedResource(
              resourceType: ShareResourceType.noteFolder,
              resourceId: childFolder.id,
              data: childFolder,
            ),
          );
        }

        continue;
      }

      final note = await _repository.getNote(
        userId: userId,
        noteId: resourceId,
      );

      if (note == null) {
        continue;
      }

      resources.add(
        CollectedResource(
          resourceType: ShareResourceType.note,
          resourceId: note.id,
          data: note,
        ),
      );
    }

    return CollectionResult(
      resources: resources,
    );
  }
}