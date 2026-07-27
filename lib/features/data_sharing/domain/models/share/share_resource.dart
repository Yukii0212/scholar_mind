import 'share_resource_dependency.dart';
import 'share_resource_metadata.dart';
import 'share_resource_reference.dart';
import 'share_resource_type.dart';

class ShareResource {
  const ShareResource({
    required this.resourceType,
    required this.resourceVersion,
    required this.resourceId,
    required this.metadata,
    required this.payload,
    this.references = const [],
    this.dependencies = const [],
  });

  final ShareResourceType resourceType;

  final int resourceVersion;

  final String resourceId;

  final ShareResourceMetadata metadata;

  final Map<String, dynamic> payload;

  final List<ShareResourceReference> references;

  final List<ShareResourceDependency> dependencies;
}