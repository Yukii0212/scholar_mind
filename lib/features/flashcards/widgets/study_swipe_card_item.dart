import 'package:flutter/widgets.dart';

import '../../../core/widgets/swipe_cards/swipe_card_item.dart';

class StudySwipeCardItem extends SwipeCardItem {
  const StudySwipeCardItem({
    required super.title,
    required super.icon,
    required super.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  /// What either direction means depends on which side of the card is
  /// showing — on the question it's always "skip" regardless of
  /// direction; on the answer, left/right are meaningfully different
  /// ("don't know" / "knew it"). The caller decides that, not this widget.
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
}