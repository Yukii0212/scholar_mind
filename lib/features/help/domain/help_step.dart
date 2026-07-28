import 'package:flutter/foundation.dart';

class HelpStep {
  const HelpStep({
    required this.description,
    this.anchorId,
    this.beforeShow,
  });

  final String description;

  /// Id of the [HelpAnchor] this step should spotlight, looked up in the
  /// same page's [HelpAnchorRegistry]. Null (or an anchor that isn't
  /// currently mounted, e.g. a different page of a swipe carousel) falls
  /// back to a centered, non-spotlit bubble for this step.
  final String? anchorId;

  /// Run right before this step tries to resolve [anchorId] (and again each
  /// time the user navigates back to this step), so a step whose element
  /// lives behind some other piece of state — a tab, a toggle — can bring
  /// it into view first instead of silently falling back to a plain bubble.
  final VoidCallback? beforeShow;
}
