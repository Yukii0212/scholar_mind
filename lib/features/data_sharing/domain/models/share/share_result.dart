class ShareResult {
  const ShareResult({
    required this.shareId,
    required this.shareUrl,
    required this.storagePath,
    required this.expiresAt,
  });

  final String shareId;
  final Uri shareUrl;
  final String storagePath;
  final DateTime? expiresAt;
}