import 'package:scholar_mind/features/data_sharing/domain/models/share_resource_type.dart';

import 'share_method.dart';

class ExportRequest {
  const ExportRequest({
    required this.resourceIds,
    required this.method,
  });

  final Map<ShareResourceType, List<String>> resourceIds;

  final ShareMethod method;
}