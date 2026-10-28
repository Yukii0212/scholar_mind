import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/models/share/share_expiry.dart';
import '../domain/models/share/share_link_record.dart';
import '../domain/models/share/share_resource_type.dart';
import '../domain/models/share/share_result.dart';

class ShareLinkService {
  const ShareLinkService();

  static final Set<String> _migratedOwners = {};
  static final Map<String, Future<void>> _ownerMigrations = {};

  Stream<List<ShareLinkRecord>> watchMyLinks(String ownerId) {
    return FirebaseFirestore.instance
        .collection('export_links')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((snapshot) async {
      await _ensureStorageAccessRecords(ownerId);

      return snapshot.docs.map(ShareLinkRecord.fromFirestore).toList();
    });
  }

  Future<void> revokeLink(String shareId) async {
    final document =
        FirebaseFirestore.instance.collection('export_links').doc(shareId);
    final snapshot = await document.get();
    final data = snapshot.data();

    if (data == null) {
      throw StateError('Share link does not exist.');
    }

    final ownerId = data['ownerId'] as String?;
    final storagePath = data['storagePath'] as String?;

    if (ownerId == null || storagePath == null) {
      throw StateError('Share link storage information is invalid.');
    }

    final location = _storageLocation(ownerId, storagePath);

    await document.update({'isRevoked': true});

    try {
      await _deleteStorageTree(
        FirebaseStorage.instance.ref(location.rootPath),
      );
    } catch (error) {
      throw ShareRevocationCleanupException(error);
    }
  }

  Future<void> incrementDownloadCount(String shareId) {
    return FirebaseFirestore.instance
        .collection('export_links')
        .doc(shareId)
        .update({'downloadCount': FieldValue.increment(1)});
  }

  Future<ShareResult> createLink({
    required String ownerId,
    required String storagePath,
    required ShareExpiry expiry,
    Map<String, int> resourceCounts = const {},
  }) async {
    final firestore = FirebaseFirestore.instance;
    final document = firestore.collection('export_links').doc();
    final location = _storageLocation(ownerId, storagePath);

    final expiresAt = expiry.calculateExpiry();

    final linkData = <String, dynamic>{
      'ownerId': ownerId,
      'storagePath': storagePath,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': expiresAt,
      'downloadCount': 0,
      'isRevoked': false,
      'resourceCounts': resourceCounts,
    };

    final batch = firestore.batch();
    batch.set(document, linkData);
    batch.set(
      firestore
          .collection('export_storage_access')
          .doc(location.storageShareId),
      _storageAccessData(
        ownerId: ownerId,
        shareLinkId: document.id,
        storagePath: storagePath,
      ),
    );
    await batch.commit();

    final url = Uri.parse(
      'scholarmind://share/${document.id}',
    );

    final typedCounts = <ShareResourceType, int>{
      for (final entry in resourceCounts.entries)
        if (ShareResourceType.fromValue(entry.key) != null)
          ShareResourceType.fromValue(entry.key)!: entry.value,
    };

    return ShareResult(
      shareId: document.id,
      shareUrl: url,
      storagePath: storagePath,
      expiresAt: expiresAt,
      resourceCounts: typedCounts,
    );
  }

  Future<void> _ensureStorageAccessRecords(
    String ownerId,
  ) async {
    if (_migratedOwners.contains(ownerId)) {
      return;
    }

    final activeMigration = _ownerMigrations[ownerId];

    if (activeMigration != null) {
      await activeMigration;
      return;
    }

    final migration = _migrateStorageAccessRecords(ownerId);
    _ownerMigrations[ownerId] = migration;

    try {
      await migration;
      _migratedOwners.add(ownerId);
    } finally {
      _ownerMigrations.remove(ownerId);
    }
  }

  Future<void> _migrateStorageAccessRecords(String ownerId) async {
    final firestore = FirebaseFirestore.instance;
    final documents = await firestore
        .collection('export_links')
        .where('ownerId', isEqualTo: ownerId)
        .get();
    final pending = <String, _StorageAccessCandidate>{};

    for (final document in documents.docs) {
      final storagePath = document.data()['storagePath'] as String?;

      if (storagePath == null) {
        continue;
      }

      final location = _storageLocation(ownerId, storagePath);
      pending[location.storageShareId] = _StorageAccessCandidate(
        shareLinkId: document.id,
        storagePath: storagePath,
      );
    }

    if (pending.isEmpty) {
      return;
    }

    final accessCollection = firestore.collection('export_storage_access');
    final existingIds = <String>{};
    final ids = pending.keys.toList();

    for (var start = 0; start < ids.length; start += 30) {
      final end = start + 30 > ids.length ? ids.length : start + 30;
      final snapshot = await accessCollection
          .where('ownerId', isEqualTo: ownerId)
          .where(
            FieldPath.documentId,
            whereIn: ids.sublist(start, end),
          )
          .get();

      existingIds.addAll(snapshot.docs.map((document) => document.id));
    }

    final missingIds = pending.keys
        .where((storageShareId) => !existingIds.contains(storageShareId))
        .toList();

    if (missingIds.isEmpty) {
      return;
    }

    for (var start = 0; start < missingIds.length; start += 20) {
      final end =
          start + 20 > missingIds.length ? missingIds.length : start + 20;
      final batch = firestore.batch();

      for (final storageShareId in missingIds.sublist(start, end)) {
        final candidate = pending[storageShareId]!;
        batch.set(
          accessCollection.doc(storageShareId),
          _storageAccessData(
            ownerId: ownerId,
            shareLinkId: candidate.shareLinkId,
            storagePath: candidate.storagePath,
          ),
        );
      }

      await batch.commit();
    }
  }

  Map<String, dynamic> _storageAccessData({
    required String ownerId,
    required String shareLinkId,
    required String storagePath,
  }) {
    return {
      'ownerId': ownerId,
      'shareLinkId': shareLinkId,
      'storagePath': storagePath,
    };
  }

  _SharedStorageLocation _storageLocation(
    String ownerId,
    String storagePath,
  ) {
    final segments = storagePath.split('/');

    if (segments.length != 5 ||
        segments[0] != 'users' ||
        segments[1] != ownerId ||
        segments[2] != 'shared_exports' ||
        segments[3].isEmpty ||
        segments[4] != 'archive.json') {
      throw StateError('Share link storage path is invalid.');
    }

    return _SharedStorageLocation(
      storageShareId: segments[3],
      rootPath: segments.take(4).join('/'),
    );
  }

  Future<void> _deleteStorageTree(Reference reference) async {
    final contents = await reference.listAll();
    Object? firstError;

    for (final item in contents.items) {
      try {
        await item.delete();
      } catch (error) {
        firstError ??= error;
      }
    }

    for (final prefix in contents.prefixes) {
      try {
        await _deleteStorageTree(prefix);
      } catch (error) {
        firstError ??= error;
      }
    }

    if (firstError != null) {
      throw firstError;
    }
  }
}

class ShareRevocationCleanupException implements Exception {
  const ShareRevocationCleanupException(this.cause);

  final Object cause;

  String get message =>
      'Link revoked, but some stored files could not be removed. '
      'Access is still blocked.';

  @override
  String toString() => message;
}

class _SharedStorageLocation {
  const _SharedStorageLocation({
    required this.storageShareId,
    required this.rootPath,
  });

  final String storageShareId;
  final String rootPath;
}

class _StorageAccessCandidate {
  const _StorageAccessCandidate({
    required this.shareLinkId,
    required this.storagePath,
  });

  final String shareLinkId;
  final String storagePath;
}
