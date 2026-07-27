import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../notes/data/data_sharing/notes_collection_service.dart';
import '../../notes/data/data_sharing/notes_data_share_handler.dart';
import '../../notes/data/repository/library_repository.dart';
import '../../notes/providers/library_provider.dart';
import '../registry/data_share_registry.dart';
import '../services/export_service.dart';

part 'export_service_provider.g.dart';

@riverpod
ExportService exportService(
    ExportServiceRef ref,
    ) {
  final repository = ref.read(
    libraryRepositoryProvider,
  );

  final registry = DataShareRegistry.instance;

  final notesHandler = NotesDataShareHandler(
    repository: repository,
    collector: NotesCollectionService(
      repository: repository,
    ),
  );

  if (registry.handlerFor(
    notesHandler.resourceTypes.first,
  ) ==
      null) {
    registry.register(
      notesHandler,
    );
  }

  return ExportService();
}