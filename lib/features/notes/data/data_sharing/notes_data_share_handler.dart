
import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../../data_sharing/domain/models/validation/validation_result.dart';
import '../../../data_sharing/registry/data_share_handler.dart';
import '../../domain/library_folder.dart';
import '../../domain/note_item.dart';
import '../library_repository.dart';
import 'notes_collection_service.dart';
import 'notes_export_mapper.dart';
import 'notes_import_mapper.dart';

class NotesDataShareHandler
    implements DataShareHandler {
  NotesDataShareHandler({
    required NotesCollectionService collector,
    NotesExportMapper? exportMapper,
    NotesImportMapper? importMapper,
  })  : _collector = collector,
        _exportMapper =
            exportMapper ?? const NotesExportMapper(),
        _importMapper =
            importMapper ?? const NotesImportMapper();

  final NotesCollectionService _collector;

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
    final collected =
    await _collector.collect(resourceIds);

    final resources = <ShareResource>[];

    for (final item in collected.resources) {
      switch (item.resourceType) {
        case ShareResourceType.note:
          resources.add(
            _exportMapper.noteToResource(
              item.data as NoteItem,
            ),
          );
          break;

        case ShareResourceType.noteFolder:
          resources.add(
            _exportMapper.folderToResource(
              item.data as LibraryFolder,
            ),
          );
          break;

        default:
          break;
      }
    }

    return resources;
  }

  @override
  Future<void> import(
      List<ShareResource> resources,
      ) async {
    // Repository integration comes next sprint.
  }
}