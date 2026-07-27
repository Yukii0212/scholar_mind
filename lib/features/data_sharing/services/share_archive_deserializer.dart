import '../domain/models/share/share_archive.dart';
import '../domain/models/share/share_manifest.dart';
import '../domain/models/share/share_resource.dart';
import '../domain/models/share/share_resource_dependency.dart';
import '../domain/models/share/share_resource_metadata.dart';
import '../domain/models/share/share_resource_reference.dart';
import '../domain/models/share/share_resource_type.dart';

class ShareArchiveDeserializer {
  const ShareArchiveDeserializer();

  ShareArchive deserialize(
      Map<String, dynamic> json,
      ) {
    final manifest =
    json['manifest'] as Map<String, dynamic>;

    final resources =
    json['resources'] as List<dynamic>;

    return ShareArchive(
      manifest: ShareManifest(
        archiveVersion:
        manifest['archiveVersion'] as int,
        createdAt: DateTime.parse(
          manifest['createdAt'] as String,
        ),
        resourceCount:
        manifest['resourceCount'] as int,
      ),
      resources: resources
          .map(
            (resource) => _deserializeResource(
          resource as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }

  ShareResource _deserializeResource(
      Map<String, dynamic> json,
      ) {
    final metadata =
    json['metadata'] as Map<String, dynamic>;

    return ShareResource(
      resourceType: ShareResourceType.fromValue(
        json['resourceType'] as String,
      )!,
      resourceVersion:
      json['resourceVersion'] as int,
      resourceId:
      json['resourceId'] as String,
      metadata: ShareResourceMetadata(
        displayName:
        metadata['displayName'] as String,
        createdAt: DateTime.parse(
          metadata['createdAt'] as String,
        ),
        updatedAt: DateTime.parse(
          metadata['updatedAt'] as String,
        ),
        tags:
        (metadata['tags'] as List<dynamic>)
            .cast<String>(),
      ),
      payload:
      Map<String, dynamic>.from(
        json['payload'] as Map,
      ),
      references:
      (json['references'] as List<dynamic>)
          .map(
            (reference) =>
            ShareResourceReference(
              resourceType:
              reference['resourceType']
              as String,
              resourceId:
              reference['resourceId']
              as String,
            ),
      )
          .toList(),
      dependencies:
      (json['dependencies']
      as List<dynamic>)
          .map(
            (dependency) =>
            ShareResourceDependency(
              resourceType:
              dependency['resourceType']
              as String,
              resourceId:
              dependency['resourceId']
              as String,
              required:
              dependency['required']
              as bool? ??
                  true,
            ),
      )
          .toList(),
    );
  }
}