import 'package:flutter/widgets.dart';

import '../../../core/widgets/swipe_cards/swipe_card_item.dart';

class StudySwipeCardItem extends SwipeCardItem {
  const StudySwipeCardItem({
    required super.title,
    required super.icon,
    required super.child,
    required this.onSkipped,
  });

  final VoidCallback onSkipped;
}