import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../../data_sharing/domain/models/validation/validation_result.dart';
import '../../../data_sharing/registry/data_share_handler.dart';
import '../../domain/countdown_item.dart';
import '../countdown_repository.dart';
import 'countdown_collection_service.dart';
import 'countdown_export_mapper.dart';
import 'countdown_import_mapper.dart';

class CountdownDataShareHandler
    implements DataShareHandler {
  CountdownDataShareHandler({
    required CountdownCollectionService collector,
    required CountdownRepository repository,
    CountdownExportMapper? exportMapper,
    CountdownImportMapper? importMapper,
  })  : _collector = collector,
        _repository = repository,
        _exportMapper =
            exportMapper ?? const CountdownExportMapper(),
        _importMapper =
            importMapper ?? const CountdownImportMapper();

  final CountdownCollectionService _collector;

  final CountdownRepository _repository;

  final CountdownExportMapper _exportMapper;

  final CountdownImportMapper _importMapper;

  @override
  List<ShareResourceType> get resourceTypes => const [
    ShareResourceType.countdown,
  ];

  @override
  ValidationResult validateExport(
      List<String> resourceIds,
      ) {
    if (resourceIds.isEmpty) {
      return const ValidationResult(
        isValid: false,
        errors: [
          'No countdowns selected.',
        ],
      );
    }

    return const ValidationResult(
      isValid: true,
    );
  }

  @override
  ValidationResult validateImport(
      ShareResource resource,
      ) {
    return const ValidationResult(
      isValid: true,
    );
  }

  @override
  Future<List<ShareResource>> export({
    required String userId,
    required List<String> resourceIds,
  }) async {
    final collected = await _collector.collect(
      userId: userId,
      resourceIds: resourceIds,
    );

    return collected.resources
        .map(_exportMapper.toResource)
        .toList();
  }

  @override
  Future<void> import({
    required String userId,
    required List<ShareResource> resources,
  }) async {
    for (final resource in resources) {
      final payload = _importMapper.payloadOf(resource);

      await _repository.importCountdown(
        userId: userId,
        title: resource.metadata.displayName,
        type: CountdownTypeLabel.fromId(
          payload['type'] as String?,
        ),
        priority: payload['priority'] as int? ?? 100,
        dueDate: DateTime.parse(
          payload['dueDate'] as String,
        ),
        description: payload['description'] as String?,
        deadlineExtendable:
        payload['deadlineExtendable'] as bool? ?? false,
      );
    }
  }
}
