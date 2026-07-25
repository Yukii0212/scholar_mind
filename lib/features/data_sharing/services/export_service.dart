import '../domain/models/export_request.dart';
import '../domain/models/share_archive.dart';
import '../domain/models/share_manifest.dart';
import '../domain/models/share_resource.dart';
import '../domain/models/share_resource_type.dart';
import '../registry/data_share_registry.dart';
import 'validation_service.dart';

class ExportService {
  ExportService({
    ValidationService? validationService,
  }) : _validationService =
      validationService ?? const ValidationService();

  final ValidationService _validationService;

  Future<ShareArchive> export(
      ExportRequest request,
      ) async {
    final List<ShareResource> resources = [];

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

      final exported =
      await handler.export(entry.value);

      resources.addAll(exported);
    }

    return ShareArchive(
      manifest: ShareManifest(
        archiveVersion: 1,
        createdAt: DateTime.now(),
        resourceCount: resources.length,
      ),
      resources: resources,
    );
  }
}