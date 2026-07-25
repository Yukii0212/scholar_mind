import '../domain/models/share_resource.dart';
import '../domain/models/validation_result.dart';

abstract class DataShareHandler {
  String get resourceType;

  ValidationResult validateExport(List<String> resourceIds);

  ValidationResult validateImport(ShareResource resource);

  Future<List<ShareResource>> export(
      List<String> resourceIds,
      );

  Future<void> import(
      List<ShareResource> resources,
      );
}