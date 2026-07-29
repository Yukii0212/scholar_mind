import 'package:flutter/material.dart';

class HelpStep {
  const HelpStep({
    required this.description,
    this.anchorId,
    this.beforeShow,
    this.colorLegend,
    this.scrimOpacity = heavyScrim,
    this.showHighlightRing = true,
  });

  /// The normal, fully-dimmed treatment used by most steps.
  static const double heavyScrim = 0.82;

  /// A much lighter dim — enough to keep some visual weight on the
  /// tutorial bubble (a fully undimmed background reads as "everything
  /// has equal priority," which defeats the point of a tutorial), while
  /// still letting the real page underneath be clearly seen. Use for a
  /// step meant to show the page itself, or the area around a spotlighted
  /// element, rather than aggressively focus attention on one small spot.
  static const double lightScrim = 0.35;

  final String description;

  /// Id of the [HelpAnchor] this step should spotlight, looked up in the
  /// same page's [HelpAnchorRegistry]. Null (or an anchor that isn't
  /// currently mounted, e.g. a different page of a swipe carousel) falls
  /// back to a centered, non-spotlit bubble for this step.
  final String? anchorId;

  /// Black-scrim opacity (0–1) painted over everything except the cutout
  /// around [anchorId] (or the whole screen, if there's no anchor). Use
  /// [heavyScrim] (default) to sharply focus one element, or [lightScrim]
  /// to keep the real page mostly visible — e.g. a step introducing the
  /// page itself, or one where the area around the anchor still matters.
  final double scrimOpacity;

  /// Whether to draw the accent-colored ring around the cutout. Turn off
  /// for a step spotlighting something whose own visual — a color-coded
  /// border, for instance — would be fought by a ring drawn over it.
  final bool showHighlightRing;

  /// Awaited right before this step tries to resolve [anchorId] (and again
  /// each time the user navigates back to this step), so a step whose
  /// element lives behind some other piece of state — a tab, a toggle, a
  /// modal that needs opening — can bring it fully into view first instead
  /// of silently falling back to a plain bubble. Do any waiting (frames,
  /// animations) inside this callback itself; it's awaited to completion
  /// before the anchor is measured.
  final Future<void> Function()? beforeShow;

  /// Optional list of (color, meaning) pairs shown as swatches under the
  /// description — for steps that explain what a color means on screen.
  /// Showing the actual color reads far more clearly than naming it (a
  /// color name like "amber" isn't something everyone recognises on sight).
  final List<HelpColorLegendEntry>? colorLegend;
}

class HelpColorLegendEntry {
  const HelpColorLegendEntry({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;
}
