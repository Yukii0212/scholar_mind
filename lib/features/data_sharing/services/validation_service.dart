import '../domain/models/share_archive.dart';
import '../domain/models/share_resource.dart';
import '../domain/models/share_resource_type.dart';
import '../domain/models/validation_result.dart';
import '../registry/data_share_registry.dart';

class ValidationService {
  const ValidationService();

  ValidationResult validateExport({
    required ShareResourceType resourceType,
    required List<String> resourceIds,
  }) {
    final handler =
    DataShareRegistry.instance.handlerFor(resourceType);

    if (handler == null) {
      return ValidationResult(
        isValid: false,
        errors: [
          'No handler registered for "$resourceType".',
        ],
      );
    }

    return handler.validateExport(resourceIds);
  }

  ValidationResult validateArchive(
      ShareArchive archive,
      ) {
    if (archive.manifest.resourceCount !=
        archive.resources.length) {
      return const ValidationResult(
        isValid: false,
        errors: [
          'Archive resource count mismatch.',
        ],
      );
    }

    return const ValidationResult(
      isValid: true,
    );
  }

  ValidationResult validateResource(
      ShareResource resource,
      ) {
    final handler = DataShareRegistry.instance.handlerFor(
      resource.resourceType,
    );

    if (handler == null) {
      return ValidationResult(
        isValid: false,
        warnings: [
          'Unsupported resource "${resource.resourceType}" skipped.',
        ],
      );
    }

    return handler.validateImport(resource);
  }
}