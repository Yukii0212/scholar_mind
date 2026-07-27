class ShareManifest {
  const ShareManifest({
    required this.archiveVersion,
    required this.createdAt,
    required this.resourceCount,
  });

  final int archiveVersion;

  final DateTime createdAt;

  final int resourceCount;
}