import 'package:flutter_test/flutter_test.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/import/import_request.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/share/share_archive.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/share/share_manifest.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/share/share_resource.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/share/share_resource_metadata.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/share/share_resource_type.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/validation/validation_result.dart';
import 'package:scholar_mind/features/data_sharing/registry/data_share_handler.dart';
import 'package:scholar_mind/features/data_sharing/registry/data_share_registry.dart';
import 'package:scholar_mind/features/data_sharing/services/import_service.dart';

void main() {
  test('invalid payloads abort before any repository-facing import', () async {
    final handler = _FakeHandler();
    DataShareRegistry.instance.register(handler);
    final resources = [
      _resource('valid', isValid: true),
      _resource('invalid', isValid: false),
    ];
    final result = await ImportService().import(
      ImportRequest(
        userId: 'user',
        archive: ShareArchive(
          manifest: ShareManifest(
            archiveVersion: 1,
            createdAt: DateTime.utc(2026),
            resourceCount: resources.length,
          ),
          resources: resources,
        ),
      ),
    );

    expect(result.success, isFalse);
    expect(result.errors, contains('Invalid countdown payload.'));
    expect(handler.importCalls, 0);
  });
}

ShareResource _resource(String id, {required bool isValid}) {
  return ShareResource(
    resourceType: ShareResourceType.countdown,
    resourceVersion: 1,
    resourceId: id,
    metadata: ShareResourceMetadata(
      displayName: id,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    payload: {'isValid': isValid},
  );
}

class _FakeHandler implements DataShareHandler {
  int importCalls = 0;

  @override
  List<ShareResourceType> get resourceTypes => const [
        ShareResourceType.countdown,
      ];

  @override
  ValidationResult validateExport(List<String> resourceIds) {
    return const ValidationResult(isValid: true);
  }

  @override
  ValidationResult validateImport(ShareResource resource) {
    if (resource.payload['isValid'] == true) {
      return const ValidationResult(isValid: true);
    }

    return const ValidationResult(
      isValid: false,
      errors: ['Invalid countdown payload.'],
    );
  }

  @override
  ValidationResult validateImportBatch(List<ShareResource> resources) {
    return const ValidationResult(isValid: true);
  }

  @override
  Future<List<ShareResource>> export({
    required String userId,
    required List<String> resourceIds,
    required String shareId,
    void Function(String message)? onProgress,
    void Function()? ensureSessionCurrent,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> import({
    required String userId,
    required List<ShareResource> resources,
    void Function()? ensureSessionCurrent,
  }) async {
    ensureSessionCurrent?.call();
    importCalls += 1;
  }
}
