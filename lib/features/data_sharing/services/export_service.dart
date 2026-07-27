import 'package:flutter/cupertino.dart';

import '../domain/models/export/export_request.dart';
import '../domain/models/share/share_archive.dart';
import '../domain/models/share/share_manifest.dart';
import '../domain/models/share/share_resource.dart';
import '../domain/models/share/share_resource_type.dart';
import '../registry/data_share_registry.dart';
import 'archive_builder_service.dart';
import 'validation_service.dart';

class ExportService {
  ExportService({
    ValidationService? validationService,
    ArchiveBuilderService? archiveBuilderService,
  })  : _validationService =
      validationService ?? const ValidationService(),
        _archiveBuilderService =
            archiveBuilderService ??
                const ArchiveBuilderService();

  final ValidationService _validationService;

  final ArchiveBuilderService _archiveBuilderService;

  Future<ShareArchive> export(
      ExportRequest request,
      ) async {
    final List<ShareResource> resources = [];

    for (final MapEntry<ShareResourceType, List<String>> entry
    in request.resourceIds.entries) {
      (
        'Exporting ${entry.key.name}: ${entry.value}',
      );

      final validation =
      _validationService.validateExport(
        resourceType: entry.key,
        resourceIds: entry.value,
      );

      if (!validation.isValid) {
        (
          'Validation failed for ${entry.key.name}',
        );
        continue;
      }

      final handler =
      DataShareRegistry.instance.handlerFor(
        entry.key,
      );

      (
        'Handler: ${handler?.runtimeType}',
      );

      if (handler == null) {
        (
          'No handler found for ${entry.key.name}',
        );
        continue;
      }

      final exported =
      await handler.export(
        userId: request.userId,
        resourceIds: entry.value,
      );

      (
        'Exported ${exported.length} resources',
      );

      resources.addAll(exported);
    }

    return _archiveBuilderService.build(
      resources,
    );
  }
}