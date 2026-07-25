import 'share_method.dart';

class ExportRequest {
  const ExportRequest({
    required this.resourceIds,
    required this.method,
  });

  final Map<String, List<String>> resourceIds;

  final ShareMethod method;
}