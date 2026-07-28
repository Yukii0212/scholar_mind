class HelpTopic {
  const HelpTopic({
    required this.id,
    required this.title,
    required this.description,
    this.anchorId,
  });

  final String id;

  final String title;

  final String description;

  /// Id of the [HelpAnchor] this topic should spotlight, looked up in the
  /// same page's [HelpAnchorRegistry]. Null for purely conceptual topics
  /// that have no single on-screen element to highlight.
  final String? anchorId;
}
