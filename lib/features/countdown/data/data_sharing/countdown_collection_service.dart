import '../../../data_sharing/collection/data_share_collector.dart';
import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/collection/collection_result.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../countdown_repository.dart';

class CountdownCollectionService implements DataShareCollector {
  CountdownCollectionService({
    required this.repository,
  });

  final CountdownRepository repository;

  @override
  ShareResourceType get resourceType => ShareResourceType.countdown;

  @override
  Future<CollectionResult> collect({
    required String userId,
    required List<String> resourceIds,
  }) async {
    final resources = <CollectedResource>[];

    for (final resourceId in resourceIds) {
      final countdown = await repository.getCountdown(
        userId: userId,
        countdownId: resourceId,
      );

      if (countdown == null) {
        continue;
      }

      resources.add(
        CollectedResource(
          resourceType: ShareResourceType.countdown,
          resourceId: countdown.id,
          data: countdown,
        ),
      );
    }

    return CollectionResult(resources: resources);
  }
}
