import '../../../data_sharing/collection/data_share_collector.dart';
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
  Future<CollectionResult> collect(
      List<String> resourceIds,
      ) async {
    // Next sprint:
    // Expand folders
    // Collect descendants
    // Remove duplicates
    // Load NoteItem + LibraryFolder

    return const CollectionResult();
  }
}