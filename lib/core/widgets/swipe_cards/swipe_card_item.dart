import 'package:flutter/cupertino.dart';

class SwipeCardItem {
  const SwipeCardItem({
    required this.title,
    required this.icon,
    required this.child,
    this.expandable = true,
  });

  final String title;

  final IconData icon;

  final Widget child;

  final bool expandable;
}