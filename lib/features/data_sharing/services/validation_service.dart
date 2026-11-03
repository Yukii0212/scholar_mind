import '../domain/models/share/share_archive.dart';
import '../domain/models/share/share_resource.dart';
import '../domain/models/share/share_resource_type.dart';
import '../domain/models/validation/validation_result.dart';
import '../registry/data_share_registry.dart';

class ValidationService {
  const ValidationService();

  ValidationResult validateExport({
    required ShareResourceType resourceType,
    required List<String> resourceIds,
  }) {
    final handler = DataShareRegistry.instance.handlerFor(resourceType);

    if (handler == null) {
      return ValidationResult(
        isValid: false,
        errors: ['No handler registered for "$resourceType".'],
      );
    }

    return handler.validateExport(resourceIds);
  }

  ValidationResult validateArchive(ShareArchive archive) {
    final errors = <String>[];
    final warnings = <String>[];

    if (archive.manifest.archiveVersion != 1) {
      errors.add(
        'Unsupported archive version ${archive.manifest.archiveVersion}.',
      );
    }

    if (archive.manifest.resourceCount != archive.resources.length) {
      errors.add('Archive resource count mismatch.');
    }

    if (archive.resources.isEmpty) {
      errors.add('Archive does not contain any resources.');
    }

    final resourceKeys = <String>{};

    for (final resource in archive.resources) {
      final key = '${resource.resourceType.value}:${resource.resourceId}';

      if (!resourceKeys.add(key)) {
        errors.add('Archive contains duplicate resource "$key".');
      }
    }

    for (final resource in archive.resources) {
      for (final dependency in resource.dependencies) {
        final dependencyType = ShareResourceType.fromValue(
          dependency.resourceType,
        );

        if (dependencyType == null) {
          errors.add(
            'Resource "${resource.resourceId}" has a dependency with an '
            'unsupported type "${dependency.resourceType}".',
          );
          continue;
        }

        final dependencyKey =
            '${dependencyType.value}:${dependency.resourceId}';

        if (resourceKeys.contains(dependencyKey)) {
          continue;
        }

        final message =
            'Resource "${resource.resourceId}" depends on missing resource '
            '"$dependencyKey".';

        if (dependency.required) {
          errors.add(message);
        } else {
          warnings.add(message);
        }
      }

      for (final reference in resource.references) {
        if (ShareResourceType.fromValue(reference.resourceType) == null) {
          errors.add(
            'Resource "${resource.resourceId}" has a reference with an '
            'unsupported type "${reference.resourceType}".',
          );
        }
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      warnings: warnings,
      errors: errors,
    );
  }

  ValidationResult validateResource(ShareResource resource) {
    final handler = DataShareRegistry.instance.handlerFor(
      resource.resourceType,
    );

    if (handler == null) {
      return ValidationResult(
        isValid: false,
        warnings: [
          'Unsupported resource "${resource.resourceType.value}" skipped.',
        ],
      );
    }

    return handler.validateImport(resource);
  }
}
