import 'package:flutter/material.dart';

class DashboardCountdownState extends InheritedWidget {
  const DashboardCountdownState({
    super.key,
    required this.pageController,
    required this.currentPage,
    required super.child,
  });

  final PageController pageController;
  final int currentPage;

  static DashboardCountdownState of(BuildContext context) {
    final state = context
        .dependOnInheritedWidgetOfExactType<DashboardCountdownState>();

    assert(state != null);

    return state!;
  }

  @override
  bool updateShouldNotify(
      DashboardCountdownState oldWidget,
      ) {
    return currentPage != oldWidget.currentPage;
  }
}