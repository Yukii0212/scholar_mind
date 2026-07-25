

import '../domain/models/validation/validation_result.dart';
import '../domain/models/share/share_resource.dart';
import '../domain/models/share/share_resource_type.dart';

abstract class DataShareHandler {
  ShareResourceType get resourceType;

  ValidationResult validateExport(
      List<String> resourceIds,
      );

  ValidationResult validateImport(
      ShareResource resource,
      );

  Future<List<ShareResource>> export(
      List<String> resourceIds,
      );

  Future<void> import(
      List<ShareResource> resources,
      );
}