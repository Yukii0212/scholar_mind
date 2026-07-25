class ShareResourceDependency {
  const ShareResourceDependency({
    required this.resourceType,
    required this.resourceId,
    this.required = true,
  });

  final String resourceType;

  final String resourceId;

  final bool required;
}