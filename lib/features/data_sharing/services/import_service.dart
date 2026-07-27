import 'package:flutter/cupertino.dart';

import '../domain/models/import/import_request.dart';
import '../domain/models/import/import_result.dart';
import '../domain/models/share/share_resource.dart';
import '../domain/models/share/share_resource_type.dart';
import '../registry/data_share_registry.dart';
import 'validation_service.dart';

class ImportService {
  ImportService({
    ValidationService? validationService,
  }) : _validationService =
      validationService ?? const ValidationService();

  final ValidationService _validationService;

  Future<ImportResult> import(
      ImportRequest request,
      ) async {
    final warnings = <String>[];
    final errors = <String>[];

    final archiveValidation =
    _validationService.validateArchive(
      request.archive,
    );

    if (!archiveValidation.isValid) {
      return ImportResult(
        success: false,
        warnings: archiveValidation.warnings,
        errors: archiveValidation.errors,
      );
    }

    final Map<ShareResourceType, List<ShareResource>>
    groupedResources = {};

    for (final resource in request.archive.resources) {
      final validation =
      _validationService.validateResource(
        resource,
      );

      if (!validation.isValid) {
        warnings.addAll(validation.warnings);
        errors.addAll(validation.errors);
        continue;
      }

      groupedResources
          .putIfAbsent(
        resource.resourceType,
            () => [],
      )
          .add(resource);
    }

    for (final handler in DataShareRegistry.instance.handlers) {
      await handler.import(
        userId: request.userId,
        resources: request.archive.resources,
      );
    }

    return ImportResult(
      success: errors.isEmpty,
      warnings: warnings,
      errors: errors,
    );
  }
}