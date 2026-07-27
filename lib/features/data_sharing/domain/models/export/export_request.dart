import '../share/share_resource_type.dart';

class ExportRequest {
  const ExportRequest({
    required this.resourceIds,
    required this.userId,
  });

  final Map<ShareResourceType, List<String>> resourceIds;

  final String userId;

}