import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_metadata.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../domain/countdown_item.dart';

class CountdownExportMapper {
  const CountdownExportMapper();

  ShareResource toResource(
      CollectedResource resource,
      ) {
    final countdown = resource.asType<CountdownItem>();

    return ShareResource(
      resourceType: ShareResourceType.countdown,
      resourceVersion: 1,
      resourceId: countdown.id,
      metadata: ShareResourceMetadata(
        displayName: countdown.title,
        createdAt: countdown.createdAt,
        updatedAt: countdown.updatedAt,
      ),
      payload: {
        'type': countdown.type.id,
        'priority': countdown.priority,
        'dueDate': countdown.dueDate.toIso8601String(),
        'description': countdown.description,
        'deadlineExtendable': countdown.deadlineExtendable,
      },
    );
  }
}
