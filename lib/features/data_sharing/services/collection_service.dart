import '../registry/data_share_collection_registry.dart';
import '../domain/models/collection/collection_result.dart';
import '../domain/models/collection/collected_resource.dart';
import '../domain/models/share/share_resource_type.dart';

class CollectionService {
  const CollectionService();

  Future<CollectionResult> collect({
    required String userId,
    required ShareResourceType resourceType,
    required List<String> resourceIds,
  }) async {
    final collector =
    DataShareCollectionRegistry.instance
        .collectorFor(resourceType);

    if (collector == null) {
      return CollectionResult(
        warnings: [
          'No collector registered for "$resourceType".',
        ],
      );
    }

    return collector.collect(
      userId: userId,
      resourceIds: resourceIds,
    );
  }
}