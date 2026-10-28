import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scholar_mind/features/data_sharing/providers/share/share_link_service_provider.dart';
import 'package:scholar_mind/features/data_sharing/providers/share/share_upload_service_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/share/share_expiry.dart';
import '../../domain/models/share/share_result.dart';
import '../../services/share_resource_summary.dart';
import 'export_request_provider.dart';
import 'export_service_provider.dart';

part 'export_controller.g.dart';

@riverpod
class ExportController extends _$ExportController {
  @override
  FutureOr<void> build() {}

  Future<ShareResult?> generateShare({
    required ShareExpiry expiry,
    required String userId,
    required void Function() ensureSessionCurrent,
    String? shareId,
    void Function(String message)? onProgress,
  }) async {
    ensureSessionCurrent();
    final request = ref.read(
      exportRequestProvider,
    );

    if (request == null) {
      return null;
    }

    if (request.userId != userId) {
      throw StateError('The export belongs to a different signed-in user.');
    }

    final resolvedShareId = shareId ?? const Uuid().v4();

    ensureSessionCurrent();
    final archive = await ref.read(exportServiceProvider).export(
          request,
          shareId: resolvedShareId,
          onProgress: onProgress,
          ensureSessionCurrent: ensureSessionCurrent,
        );

    ensureSessionCurrent();
    onProgress?.call('Uploading share archive...');

    final storagePath = await ref
        .read(
          shareUploadServiceProvider,
        )
        .uploadArchive(
          userId: request.userId,
          shareId: resolvedShareId,
          archive: archive,
        );

    ensureSessionCurrent();
    onProgress?.call('Finalizing share link...');

    final result = await ref
        .read(
          shareLinkServiceProvider,
        )
        .createLink(
          ownerId: request.userId,
          storagePath: storagePath,
          expiry: expiry,
          resourceCounts: summarizeResources(archive.resources),
        );

    ensureSessionCurrent();
    return result;
  }
}
