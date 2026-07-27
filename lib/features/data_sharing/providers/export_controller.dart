import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scholar_mind/features/data_sharing/providers/share_link_service_provider.dart';
import 'package:scholar_mind/features/data_sharing/providers/share_upload_service_provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/share/share_archive.dart';
import '../domain/models/share/share_expiry.dart';
import '../domain/models/share/share_result.dart';
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

  Future<ShareResult?> generateShare({
    required ShareExpiry expiry,
  }) async {
    final request = ref.read(
      exportRequestProvider,
    );

    if (request == null) {
      return null;
    }

    state = const AsyncLoading();

    try {
      final archive = await ref
          .read(exportServiceProvider)
          .export(request);

      final shareId = const Uuid().v4();

      final storagePath = await ref
          .read(
        shareUploadServiceProvider,
      )
          .uploadArchive(
        shareId: shareId,
        archive: archive,
      );

      final result = await ref
          .read(
        shareLinkServiceProvider,
      )
          .createLink(
        ownerId: request.userId,
        storagePath: storagePath,
        expiry: expiry,
      );

      state = const AsyncData(null);

      return result;
    } catch (e, st) {
      state = AsyncError(
        e,
        st,
      );

      rethrow;
    }
  }
}