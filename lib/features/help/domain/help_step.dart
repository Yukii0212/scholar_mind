class HelpStep {
  const HelpStep({
    required this.description,
    this.anchorId,
  });

  final String description;

  /// Id of the [HelpAnchor] this step should spotlight, looked up in the
  /// same page's [HelpAnchorRegistry]. Null (or an anchor that isn't
  /// currently mounted, e.g. a different page of a swipe carousel) falls
  /// back to a centered, non-spotlit bubble for this step.
  final String? anchorId;
}
