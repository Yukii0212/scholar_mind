import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/share/share_archive.dart';
import 'export_request_provider.dart';
import 'export_service_provider.dart';

part 'export_controller.g.dart';

@riverpod
class ExportController
    extends _$ExportController {
  @override
  FutureOr<void> build() {}

  Future<ShareArchive?> export() async {
    final request = ref.read(
      exportRequestProvider,
    );

    if (request == null) {
      return null;
    }

    state = const AsyncLoading();

    final archive = await ref
        .read(exportServiceProvider)
        .export(request);

    state = const AsyncData(null);

    return archive;
  }
}