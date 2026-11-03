import '../domain/models/share/share_archive.dart';
import '../domain/models/share/share_manifest.dart';
import '../domain/models/share/share_resource.dart';
import '../domain/models/share/share_resource_dependency.dart';
import '../domain/models/share/share_resource_metadata.dart';
import '../domain/models/share/share_resource_reference.dart';
import '../domain/models/share/share_resource_type.dart';

class ShareArchiveDeserializer {
  const ShareArchiveDeserializer();

  ShareArchive deserialize(Map<String, dynamic> json) {
    try {
      final manifest = _readMap(json['manifest'], 'manifest');
      final resourceJson = _readList(json['resources'], 'resources');

      return ShareArchive(
        manifest: ShareManifest(
          archiveVersion: _readInt(
            manifest['archiveVersion'],
            'manifest.archiveVersion',
          ),
          createdAt: _readDate(
            manifest['createdAt'],
            'manifest.createdAt',
          ),
          resourceCount: _readInt(
            manifest['resourceCount'],
            'manifest.resourceCount',
          ),
        ),
        resources: List<ShareResource>.unmodifiable(
          resourceJson.indexed.map(
            (entry) => _deserializeResource(
              _readMap(entry.$2, 'resources[${entry.$1}]'),
              entry.$1,
            ),
          ),
        ),
      );
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException('Invalid share archive: $error');
    }
  }

  ShareResource _deserializeResource(
    Map<String, dynamic> json,
    int index,
  ) {
    final path = 'resources[$index]';
    final typeValue = _readString(
      json['resourceType'],
      '$path.resourceType',
    );
    final resourceType = ShareResourceType.fromValue(typeValue);

    if (resourceType == null) {
      throw FormatException(
        'Unsupported resource type "$typeValue" at $path.resourceType.',
      );
    }

    final metadata = _readMap(json['metadata'], '$path.metadata');
    final references = json['references'] == null
        ? const <dynamic>[]
        : _readList(json['references'], '$path.references');
    final dependencies = json['dependencies'] == null
        ? const <dynamic>[]
        : _readList(json['dependencies'], '$path.dependencies');

    return ShareResource(
      resourceType: resourceType,
      resourceVersion: _readInt(
        json['resourceVersion'],
        '$path.resourceVersion',
      ),
      resourceId: _readString(json['resourceId'], '$path.resourceId'),
      metadata: ShareResourceMetadata(
        displayName: _readString(
          metadata['displayName'],
          '$path.metadata.displayName',
        ),
        createdAt: _readDate(
          metadata['createdAt'],
          '$path.metadata.createdAt',
        ),
        updatedAt: _readDate(
          metadata['updatedAt'],
          '$path.metadata.updatedAt',
        ),
        tags: metadata['tags'] == null
            ? const []
            : _readStringList(metadata['tags'], '$path.metadata.tags'),
      ),
      payload: _readMap(json['payload'], '$path.payload'),
      references: List<ShareResourceReference>.unmodifiable(
        references.indexed.map((entry) {
          final reference = _readMap(
            entry.$2,
            '$path.references[${entry.$1}]',
          );

          return ShareResourceReference(
            resourceType: _readString(
              reference['resourceType'],
              '$path.references[${entry.$1}].resourceType',
            ),
            resourceId: _readString(
              reference['resourceId'],
              '$path.references[${entry.$1}].resourceId',
            ),
          );
        }),
      ),
      dependencies: List<ShareResourceDependency>.unmodifiable(
        dependencies.indexed.map((entry) {
          final dependency = _readMap(
            entry.$2,
            '$path.dependencies[${entry.$1}]',
          );
          final required = dependency['required'];

          if (required != null && required is! bool) {
            throw FormatException(
              '$path.dependencies[${entry.$1}].required must be a boolean.',
            );
          }

          return ShareResourceDependency(
            resourceType: _readString(
              dependency['resourceType'],
              '$path.dependencies[${entry.$1}].resourceType',
            ),
            resourceId: _readString(
              dependency['resourceId'],
              '$path.dependencies[${entry.$1}].resourceId',
            ),
            required: required as bool? ?? true,
          );
        }),
      ),
    );
  }

  Map<String, dynamic> _readMap(dynamic value, String path) {
    if (value is! Map) {
      throw FormatException('$path must be an object.');
    }

    try {
      return Map<String, dynamic>.from(value);
    } on TypeError {
      throw FormatException('$path must have string keys.');
    }
  }

  List<dynamic> _readList(dynamic value, String path) {
    if (value is! List) {
      throw FormatException('$path must be a list.');
    }

    return List<dynamic>.from(value);
  }

  String _readString(dynamic value, String path) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$path must be a non-empty string.');
    }

    return value;
  }

  int _readInt(dynamic value, String path) {
    if (value is! int) {
      throw FormatException('$path must be an integer.');
    }

    return value;
  }

  DateTime _readDate(dynamic value, String path) {
    final raw = _readString(value, path);
    final date = DateTime.tryParse(raw);

    if (date == null) {
      throw FormatException('$path must be an ISO-8601 date.');
    }

    return date;
  }

  List<String> _readStringList(dynamic value, String path) {
    final items = _readList(value, path);

    if (items.any((item) => item is! String)) {
      throw FormatException('$path must contain only strings.');
    }

    return items.cast<String>();
  }
}
