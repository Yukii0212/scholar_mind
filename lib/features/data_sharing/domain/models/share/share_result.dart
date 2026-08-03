import 'share_resource_type.dart';

class ShareResult {
  const ShareResult({
    required this.shareId,
    required this.shareUrl,
    required this.storagePath,
    required this.expiresAt,
    this.resourceCounts = const {},
  });

  final String shareId;
  final Uri shareUrl;
  final String storagePath;
  final DateTime? expiresAt;
  final Map<ShareResourceType, int> resourceCounts;
}