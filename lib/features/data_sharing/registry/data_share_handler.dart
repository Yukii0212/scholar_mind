import '../domain/models/validation/validation_result.dart';
import '../domain/models/share/share_resource.dart';
import '../domain/models/share/share_resource_type.dart';

abstract class DataShareHandler {
  List<ShareResourceType> get resourceTypes;

  ValidationResult validateExport(
      List<String> resourceIds,
      );

  ValidationResult validateImport(
      ShareResource resource,
      );

  Future<List<ShareResource>> export({
    required String userId,
    required List<String> resourceIds,
  });

  Future<void> import({
    required String userId,
    required List<ShareResource> resources,
  });
}