import '../share/share_resource_type.dart';

class CollectedResource {
  const CollectedResource({
    required this.resourceType,
    required this.resourceId,
    required this.data,
  });

  final ShareResourceType resourceType;

  final String resourceId;

  final Object data;

  T asType<T>() => data as T;
}