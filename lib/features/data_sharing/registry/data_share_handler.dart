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
    // The share this export belongs to, generated once up front by the
    // caller and reused for the eventual archive upload — handlers whose
    // resources include files of their own (e.g. notes) need it to know
    // where to copy those files to, so they can be referenced by path
    // from the archive instead of embedding their bytes inline.
    required String shareId,
  });

  Future<void> import({
    required String userId,
    required List<ShareResource> resources,
  });
}