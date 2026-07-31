import 'package:cloud_firestore/cloud_firestore.dart';

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
  });

  final String shareId;
  final String storagePath;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final int downloadCount;
  final bool isRevoked;

  Uri get shareUrl => Uri.parse('scholarmind://share/$shareId');

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  factory ShareLinkRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};

    return ShareLinkRecord(
      shareId: doc.id,
      storagePath: data['storagePath'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      downloadCount: data['downloadCount'] as int? ?? 0,
      isRevoked: data['isRevoked'] as bool? ?? false,
    );
  }
}
