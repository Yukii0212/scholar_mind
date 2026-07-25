import '../../../data_sharing/domain/models/share_resource.dart';
import '../../../data_sharing/domain/models/share_resource_type.dart';
import '../../../data_sharing/domain/models/validation_result.dart';
import '../../../data_sharing/registry/data_share_handler.dart';
import '../library_repository.dart';
import 'notes_export_mapper.dart';
import 'notes_import_mapper.dart';

class NotesDataShareHandler
    implements DataShareHandler {
  NotesDataShareHandler({
    required LibraryRepository repository,
    NotesExportMapper? exportMapper,
    NotesImportMapper? importMapper,
  })  : _repository = repository,
        _exportMapper =
            exportMapper ?? const NotesExportMapper(),
        _importMapper =
            importMapper ?? const NotesImportMapper();

  final LibraryRepository _repository;

  final NotesExportMapper _exportMapper;

  final NotesImportMapper _importMapper;

  @override
  ShareResourceType get resourceType =>
      ShareResourceType.note;

  @override
  ValidationResult validateExport(
      List<String> resourceIds,
      ) {
    if (resourceIds.isEmpty) {
      return const ValidationResult(
        isValid: false,
        errors: [
          'No notes selected.',
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
  Future<List<ShareResource>> export(
      List<String> resourceIds,
      ) async {
    // Repository integration comes next sprint.
    return [];
  }

  @override
  Future<void> import(
      List<ShareResource> resources,
      ) async {
    // Repository integration comes next sprint.
  }
}