import 'package:flutter/material.dart';

import '../../../../core/theme/app_design.dart';
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
  static const _pages = [
    CountdownDashboardCard(),
    DashboardCalendarPage(),
  ];

  int _currentPage = 0;

  void _switchPage(int delta) {
    setState(() {
      _currentPage =
          (_currentPage + delta + _pages.length) % _pages.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The countdown list and the calendar grid are structurally different
    // amounts of content (a handful of rows vs. a full month grid), so
    // forcing them to the same height either leaves dead space under the
    // shorter one or requires hacks that don't hold up across content/
    // screen sizes. Instead each page keeps its own natural height, and
    // AnimatedSize smooths the transition into a graceful resize instead of
    // an abrupt jump.
    return Column(
      children: [
        AnimatedSize(
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
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_currentPage),
              child: _pages[_currentPage],
            ),
          ),
        ),

        const SizedBox(height: 10),

        _ViewSwitchBar(
          currentPage: _currentPage,
          pageCount: _pages.length,
          onSwipe: _switchPage,
          onDotSelected: (index) {
            setState(() {
              _currentPage = index;
            });
          },
        ),
      ],
    );
  }
}

// Page-switching lives exclusively in this strip so the calendar page above
// is free to use horizontal swipes for its own month navigation without any
// gesture competing for the same pointer.
class _ViewSwitchBar extends StatelessWidget {
  const _ViewSwitchBar({
    required this.currentPage,
    required this.pageCount,
    required this.onSwipe,
    required this.onDotSelected,
  });

  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onSwipe;
  final ValueChanged<int> onDotSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;

        if (velocity < -100) {
          onSwipe(1);
        } else if (velocity > 100) {
          onSwipe(-1);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: palette.panelStrong.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.stroke.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chevron_left_rounded,
              size: 16,
              color: palette.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              'Swipe to switch view',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: palette.textMuted,
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(pageCount, (index) {
                return GestureDetector(
                  onTap: () => onDotSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: currentPage == index ? 18 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: .35),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
