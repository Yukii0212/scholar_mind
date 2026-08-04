import 'package:cloud_firestore/cloud_firestore.dart';

import 'share_resource_type.dart';

/// A previously generated share link, as listed in the "My shared links"
/// history screen — distinct from [ShareResult], which is only the
/// short-lived result of a single just-completed export.
class ShareLinkRecord {
  const ShareLinkRecord({
    required this.shareId,
    required this.storagePath,
    required this.createdAt,
    required this.expiresAt,
    required this.downloadCount,
    required this.isRevoked,
    required this.resourceCounts,
  });

  final String shareId;
  final String storagePath;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final int downloadCount;
  final bool isRevoked;
  final Map<ShareResourceType, int> resourceCounts;

  Uri get shareUrl => Uri.parse('scholarmind://share/$shareId');

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  /// e.g. "12 notes, 2 folders" — what this link actually contains, which
  /// is what a user glancing at the list actually wants to know. Falls
  /// back to a generic label for links created before this was tracked.
  String get contentsSummary {
    if (resourceCounts.isEmpty) {
      return 'Shared materials';
    }

    return resourceCounts.entries
        .map((entry) => '${entry.value} ${entry.key.pluralLabel(entry.value)}')
        .join(', ');
  }

  factory ShareLinkRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};

    final rawCounts = data['resourceCounts'] as Map<String, dynamic>? ?? const {};

    final resourceCounts = <ShareResourceType, int>{};

    for (final entry in rawCounts.entries) {
      final type = ShareResourceType.fromValue(entry.key);

      if (type != null) {
        resourceCounts[type] = (entry.value as num).toInt();
      }
    }

    return ShareLinkRecord(
      shareId: doc.id,
      storagePath: data['storagePath'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      downloadCount: data['downloadCount'] as int? ?? 0,
      isRevoked: data['isRevoked'] as bool? ?? false,
      resourceCounts: resourceCounts,
    );
  }
}
