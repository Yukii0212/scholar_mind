import 'package:flutter/material.dart';

class SwipeCardItem {
  const SwipeCardItem({
    required this.title,
    required this.icon,
    required this.height,
    required this.child,
  });

  final String title;

  final IconData icon;

  final double height;

  final Widget child;
}