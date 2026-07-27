import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../domain/models/import/import_request.dart';
import '../domain/models/import/import_result.dart';
import '../domain/models/share/share_archive.dart';
import '../providers/share_archive_deserializer_provider.dart';
import '../providers/share_download_service_provider.dart';
import '../providers/share_lookup_service_provider.dart';
import '../providers/import_service_provider.dart';
import '../providers/validation_service_provider.dart';

part 'share_import_controller.g.dart';

@riverpod
class ShareImportController extends _$ShareImportController {
  @override
  FutureOr<void> build() {}

  Future<ShareArchive> importFromShareId(
      String shareId,
      ) async {
    final snapshot = await ref
        .read(
      shareLookupServiceProvider,
    )
        .lookup(shareId);

    if (!snapshot.exists) {
      throw Exception(
        'Share link does not exist.',
      );
    }

    final data = snapshot.data();

    if (data == null) {
      throw Exception(
        'Invalid share link.',
      );
    }

    if (data['isRevoked'] == true) {
      throw Exception(
        'This share link has been revoked.',
      );
    }

    final expiresAt = data['expiresAt'];

    if (expiresAt != null) {
      final expiry =
      (expiresAt as dynamic).toDate()
      as DateTime;

      if (DateTime.now().isAfter(expiry)) {
        throw Exception(
          'This share link has expired.',
        );
      }
    }

    final storagePath =
    data['storagePath'] as String;

    final archiveJson = await ref
        .read(
      shareDownloadServiceProvider,
    )
        .downloadArchive(storagePath);

    final archive = ref
        .read(
      shareArchiveDeserializerProvider,
    )
        .deserialize(archiveJson);

    final validation = ref
        .read(
      validationServiceProvider,
    )
        .validateArchive(
      archive,
    );

    if (!validation.isValid) {
      throw Exception(
        validation.errors.join('\n'),
      );
    }

    return archive;
  }

  Future<ImportResult> importArchive(
      ShareArchive archive,
      ) {
    final user = ref.read(firebaseAuthProvider).currentUser;

    if (user == null) {
      throw Exception(
        'You must be signed in to import shared data.',
      );
    }

    return ref
        .read(
      importServiceProvider,
    )
        .import(
      ImportRequest(
        userId: user.uid,
        archive: archive,
      ),
    );
  }
}

