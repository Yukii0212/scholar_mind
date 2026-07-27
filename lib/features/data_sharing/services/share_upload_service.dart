import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/models/share/share_archive.dart';
import '../domain/models/share/share_resource.dart';

class ShareUploadService {
  const ShareUploadService();

  Future<String> uploadArchive({
    required String userId,
    required String shareId,
    required ShareArchive archive,
  }) async {
    final json = jsonEncode(
      _serializeArchive(archive),
    );

    final storagePath =
        'users/$userId/shared_exports/$shareId/archive.json';

    final reference =
    FirebaseStorage.instance.ref(storagePath);

    await reference.putString(
      json,
      format: PutStringFormat.raw,
      metadata: SettableMetadata(
        contentType: 'application/json',
      ),
    );

    return storagePath;
  }

  Map<String, dynamic> _serializeArchive(
      ShareArchive archive,
      ) {
    return {
      'manifest': {
        'archiveVersion':
        archive.manifest.archiveVersion,
        'createdAt':
        archive.manifest.createdAt.toIso8601String(),
        'resourceCount':
        archive.manifest.resourceCount,
      },
      'resources': archive.resources
          .map(_serializeResource)
          .toList(),
    };
  }

  Map<String, dynamic> _serializeResource(
      ShareResource resource,
      ) {
    return {
      'resourceType': resource.resourceType.name,
      'resourceVersion': resource.resourceVersion,
      'resourceId': resource.resourceId,
      'metadata': {
        'displayName': resource.metadata.displayName,
        'createdAt':
        resource.metadata.createdAt.toIso8601String(),
        'updatedAt':
        resource.metadata.updatedAt.toIso8601String(),
        'tags': resource.metadata.tags,
      },
      'payload': resource.payload,
      'references': resource.references
          .map(
            (reference) => {
              'resourceType': resource.resourceType,
          'resourceId':
          reference.resourceId,
        },
      )
          .toList(),
      'dependencies': resource.dependencies
          .map(
            (dependency) => {
          'resourceType':
          dependency.resourceType,
          'resourceId':
          dependency.resourceId,
        },
      )
          .toList(),
    };
  }
}