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

  if (registry.handlerFor(
    NotesDataShareHandler(
      repository: repository,
      collector: NotesCollectionService(
        repository: repository,
      ),
    ).resourceType,
  ) ==
      null) {
    registry.register(
        NotesDataShareHandler(
          repository: repository,
          collector: NotesCollectionService(
            repository: repository,
          ),
        )
    );
  }

  return ExportService();
}