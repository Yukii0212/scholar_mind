import 'package:flutter/material.dart';

import '../../../countdown/widgets/countdown_dashboard_card.dart';
import 'dashboard_calendar_page.dart';

class DashboardCountdownCarousel extends StatefulWidget {
  const DashboardCountdownCarousel({super.key});

  @override
  State<DashboardCountdownCarousel> createState() =>
      _DashboardCountdownCarouselState();
}

class _DashboardCountdownCarouselState
    extends State<DashboardCountdownCarousel> {

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      CountdownDashboardCard(),
      DashboardCalendarPage(),
    ];

    return Column(
      children: [
        GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;

            if (velocity < -100) {
              setState(() {
                _currentPage = (_currentPage + 1) % pages.length;
              });
            } else if (velocity > 100) {
              setState(() {
                _currentPage =
                    (_currentPage - 1 + pages.length) % pages.length;
              });
            }
          },
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_currentPage),
                child: pages[_currentPage],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            2,
                (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _currentPage = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _currentPage == index ? 18 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: .35),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}