import '../domain/models/collection/collection_result.dart';
import '../domain/models/share/share_resource_type.dart';

abstract class DataShareCollector {
  ShareResourceType get resourceType;

  Future<CollectionResult> collect(
      List<String> resourceIds,
      );
}