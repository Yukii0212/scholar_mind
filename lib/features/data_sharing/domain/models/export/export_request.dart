import '../share/share_method.dart';
import '../share/share_resource_type.dart';

class ExportRequest {
  const ExportRequest({
    required this.resourceIds,
    required this.userId,
    required this.method,
  });

  final Map<ShareResourceType, List<String>> resourceIds;

  final String userId;

  final ShareMethod method;
}