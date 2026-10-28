import '../domain/models/import/import_request.dart';
import '../domain/models/import/import_result.dart';
import '../domain/models/share/share_resource.dart';
import '../domain/models/share/share_resource_type.dart';
import '../registry/data_share_handler.dart';
import '../registry/data_share_registry.dart';
import 'validation_service.dart';

class ImportService {
  ImportService({
    ValidationService? validationService,
  }) : _validationService = validationService ?? const ValidationService();

  final ValidationService _validationService;

  Future<ImportResult> import(
    ImportRequest request, {
    void Function()? ensureSessionCurrent,
  }) async {
    ensureSessionCurrent?.call();
    final warnings = <String>[];
    final errors = <String>[];
    final archiveValidation = _validationService.validateArchive(
      request.archive,
    );

    warnings.addAll(archiveValidation.warnings);
    errors.addAll(archiveValidation.errors);

    if (!archiveValidation.isValid) {
      return ImportResult(
        success: false,
        warnings: warnings,
        errors: errors,
      );
    }

    final groupedResources = <ShareResourceType, List<ShareResource>>{};

    for (final resource in request.archive.resources) {
      ensureSessionCurrent?.call();
      final validation = _validationService.validateResource(resource);

      warnings.addAll(validation.warnings);
      errors.addAll(validation.errors);

      if (!validation.isValid) {
        continue;
      }

      groupedResources
          .putIfAbsent(resource.resourceType, () => [])
          .add(resource);
    }

    if (errors.isNotEmpty) {
      return ImportResult(
        success: false,
        warnings: warnings,
        errors: errors,
      );
    }

    final importWork = <DataShareHandler, List<ShareResource>>{};

    for (final handler in DataShareRegistry.instance.handlers) {
      ensureSessionCurrent?.call();
      final resources = <ShareResource>[];

      for (final resourceType in handler.resourceTypes) {
        resources.addAll(groupedResources[resourceType] ?? const []);
      }

      if (resources.isEmpty) {
        continue;
      }

      final validation = handler.validateImportBatch(resources);
      warnings.addAll(validation.warnings);
      errors.addAll(validation.errors);

      if (validation.isValid) {
        importWork[handler] = resources;
      }
    }

    if (errors.isNotEmpty) {
      return ImportResult(
        success: false,
        warnings: warnings,
        errors: errors,
      );
    }

    for (final entry in importWork.entries) {
      try {
        ensureSessionCurrent?.call();
        await entry.key.import(
          userId: request.userId,
          resources: entry.value,
          ensureSessionCurrent: ensureSessionCurrent,
        );
        ensureSessionCurrent?.call();
      } catch (error) {
        errors.add(
          'Import failed while processing ${entry.key.runtimeType}: $error',
        );
        break;
      }
    }

    return ImportResult(
      success: errors.isEmpty,
      warnings: warnings,
      errors: errors,
    );
  }
}
