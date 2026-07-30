import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scholar_mind/features/data_sharing/providers/share/share_link_service_provider.dart';
import 'package:scholar_mind/features/data_sharing/providers/share/share_upload_service_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/share/share_expiry.dart';
import '../../domain/models/share/share_result.dart';
import 'export_request_provider.dart';
import 'export_service_provider.dart';

part 'export_controller.g.dart';

@riverpod
class ExportController
    extends _$ExportController {
  @override
  FutureOr<void> build() {}

  Future<ShareResult?> generateShare({
    required ShareExpiry expiry,
  }) async {
    final request = ref.read(
      exportRequestProvider,
    );

    if (request == null) {
      return null;
    }

    final shareId = const Uuid().v4();

    final archive = await ref
        .read(exportServiceProvider)
        .export(request, shareId: shareId);

    final storagePath = await ref
        .read(
      shareUploadServiceProvider,
    )
        .uploadArchive(
      userId: request.userId,
      shareId: shareId,
      archive: archive,
    );

    return ref
        .read(
      shareLinkServiceProvider,
    )
        .createLink(
      ownerId: request.userId,
      storagePath: storagePath,
      expiry: expiry,
    );
  }
}