import '../domain/models/export/export_request.dart';
import '../domain/models/share/share_archive.dart';
import '../domain/models/share/share_resource.dart';
import '../domain/models/share/share_resource_type.dart';
import '../registry/data_share_handler.dart';
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

    final Map<DataShareHandler, Set<String>>
    resourceIdsByHandler = {};

    for (final MapEntry<ShareResourceType, List<String>> entry
    in request.resourceIds.entries) {
      final validation =
      _validationService.validateExport(
        resourceType: entry.key,
        resourceIds: entry.value,
      );

      if (!validation.isValid) {
        continue;
      }

      final handler =
      DataShareRegistry.instance.handlerFor(
        entry.key,
      );

      if (handler == null) {
        continue;
      }

      resourceIdsByHandler
          .putIfAbsent(
        handler,
            () => <String>{},
      )
          .addAll(entry.value);
    }

    for (final entry in resourceIdsByHandler.entries) {
      final exported =
      await entry.key.export(
        userId: request.userId,
        resourceIds: entry.value.toList(),
      );

      resources.addAll(exported);
    }

    return _archiveBuilderService.build(
      resources,
    );
  }
}