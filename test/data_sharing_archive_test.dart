import 'package:flutter_test/flutter_test.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/share/share_archive.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/share/share_manifest.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/share/share_resource.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/share/share_resource_dependency.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/share/share_resource_metadata.dart';
import 'package:scholar_mind/features/data_sharing/domain/models/share/share_resource_type.dart';
import 'package:scholar_mind/features/data_sharing/services/share_archive_deserializer.dart';
import 'package:scholar_mind/features/data_sharing/services/validation_service.dart';

void main() {
  group('ShareArchive', () {
    test('withResources rebuilds the manifest count', () {
      final archive = _archive([
        _resource('one'),
        _resource('two'),
      ]);

      final filtered = archive.withResources([archive.resources.first]);

      expect(filtered.manifest.resourceCount, 1);
      expect(filtered.resources, hasLength(1));
      expect(filtered.manifest.createdAt, archive.manifest.createdAt);
    });

    test('duplicate resources are rejected before import', () {
      final resource = _resource('duplicate');
      final result = const ValidationService().validateArchive(
        _archive([resource, resource]),
      );

      expect(result.isValid, isFalse);
      expect(result.errors.single, contains('duplicate resource'));
    });

    test('missing required dependencies are rejected before import', () {
      final resource = ShareResource(
        resourceType: ShareResourceType.countdown,
        resourceVersion: 1,
        resourceId: 'dependent',
        metadata: ShareResourceMetadata(
          displayName: 'dependent',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
        payload: const {},
        dependencies: const [
          ShareResourceDependency(
            resourceType: 'countdown',
            resourceId: 'missing',
          ),
        ],
      );

      final result = const ValidationService().validateArchive(
        _archive([resource]),
      );

      expect(result.isValid, isFalse);
      expect(result.errors.single, contains('missing resource'));
    });
  });

  group('ShareArchiveDeserializer', () {
    const deserializer = ShareArchiveDeserializer();

    test('reports unknown resource types as a format error', () {
      final json = _archiveJson();
      (json['resources'] as List<dynamic>).first['resourceType'] =
          'future_resource';

      expect(
        () => deserializer.deserialize(json),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('Unsupported resource type'),
          ),
        ),
      );
    });

    test('reports malformed payloads with their field path', () {
      final json = _archiveJson();
      (json['resources'] as List<dynamic>).first['payload'] = 'invalid';

      expect(
        () => deserializer.deserialize(json),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('resources[0].payload'),
          ),
        ),
      );
    });
  });
}

ShareArchive _archive(List<ShareResource> resources) {
  return ShareArchive(
    manifest: ShareManifest(
      archiveVersion: 1,
      createdAt: DateTime.utc(2026),
      resourceCount: resources.length,
    ),
    resources: resources,
  );
}

ShareResource _resource(String id) {
  return ShareResource(
    resourceType: ShareResourceType.countdown,
    resourceVersion: 1,
    resourceId: id,
    metadata: ShareResourceMetadata(
      displayName: id,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    payload: const {
      'type': 'assignment',
      'priority': 1,
      'dueDate': '2026-12-01T00:00:00.000Z',
      'deadlineExtendable': false,
    },
  );
}

Map<String, dynamic> _archiveJson() {
  return {
    'manifest': {
      'archiveVersion': 1,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'resourceCount': 1,
    },
    'resources': [
      {
        'resourceType': 'countdown',
        'resourceVersion': 1,
        'resourceId': 'countdown-1',
        'metadata': {
          'displayName': 'Deadline',
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
          'tags': <String>[],
        },
        'payload': {
          'type': 'assignment',
          'priority': 1,
          'dueDate': '2026-12-01T00:00:00.000Z',
          'deadlineExtendable': false,
        },
        'references': <dynamic>[],
        'dependencies': <dynamic>[],
      },
    ],
  };
}
