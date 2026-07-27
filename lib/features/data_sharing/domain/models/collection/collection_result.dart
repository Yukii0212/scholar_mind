import 'collected_resource.dart';

class CollectionResult {
  const CollectionResult({
    this.resources = const [],
    this.warnings = const [],
  });

  final List<CollectedResource> resources;

  final List<String> warnings;
}