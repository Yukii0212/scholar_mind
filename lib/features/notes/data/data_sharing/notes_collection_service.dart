import '../../../data_sharing/collection/data_share_collector.dart';
import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/collection/collection_result.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../repository/library_repository.dart';

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
    final visitedFolders = <String>{};
    final visitedNotes = <String>{};

    for (final resourceId in resourceIds) {
      await _collectResource(
        userId: userId,
        resourceId: resourceId,
        resources: resources,
        visitedFolders: visitedFolders,
        visitedNotes: visitedNotes,
      );
    }

    return CollectionResult(
      resources: resources,
    );
  }

  Future<void> _collectResource({
    required String userId,
    required String resourceId,
    required List<CollectedResource> resources,
    required Set<String> visitedFolders,
    required Set<String> visitedNotes,
  }) async {
    final folder = await _repository.getFolder(
      userId: userId,
      folderId: resourceId,
    );

    if (folder != null) {
      await _collectFolder(
        userId: userId,
        folderId: folder.id,
        resources: resources,
        visitedFolders: visitedFolders,
        visitedNotes: visitedNotes,
      );
      return;
    }

    final note = await _repository.getNote(
      userId: userId,
      noteId: resourceId,
    );

    if (note == null || !visitedNotes.add(note.id)) {
      return;
    }

    resources.add(
      CollectedResource(
        resourceType: ShareResourceType.note,
        resourceId: note.id,
        data: note,
      ),
    );
  }

  Future<void> _collectFolder({
    required String userId,
    required String folderId,
    required List<CollectedResource> resources,
    required Set<String> visitedFolders,
    required Set<String> visitedNotes,
  }) async {
    if (!visitedFolders.add(folderId)) {
      return;
    }

    final folder = await _repository.getFolder(
      userId: userId,
      folderId: folderId,
    );

    if (folder == null) {
      return;
    }

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
      if (!visitedNotes.add(note.id)) {
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

    final childFolders = await _repository.getChildFolders(
      userId: userId,
      parentFolderId: folder.id,
    );

    for (final child in childFolders) {
      await _collectFolder(
        userId: userId,
        folderId: child.id,
        resources: resources,
        visitedFolders: visitedFolders,
        visitedNotes: visitedNotes,
      );
    }
  }
}