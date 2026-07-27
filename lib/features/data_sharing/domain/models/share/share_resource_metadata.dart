class ShareResourceMetadata {
  const ShareResourceMetadata({
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  final String displayName;

  final DateTime createdAt;

  final DateTime updatedAt;

  final List<String> tags;
}