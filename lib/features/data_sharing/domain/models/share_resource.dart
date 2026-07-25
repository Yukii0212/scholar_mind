class ShareResource {
  const ShareResource({
    required this.resourceType,
    required this.resourceVersion,
    required this.resourceId,
    required this.payload,
  });

  final String resourceType;

  final int resourceVersion;

  final String resourceId;

  final Map<String, dynamic> payload;
}