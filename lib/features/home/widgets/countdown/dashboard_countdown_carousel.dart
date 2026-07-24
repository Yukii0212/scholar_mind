import 'package:flutter/material.dart';

import '../../../countdown/widgets/countdown_dashboard_card.dart';
import 'dashboard_calendar_page.dart';
import 'dashboard_countdown_state.dart';

class DashboardCountdownCarousel extends StatefulWidget {
  const DashboardCountdownCarousel({super.key});

  @override
  State<DashboardCountdownCarousel> createState() =>
      _DashboardCountdownCarouselState();
}

class _DashboardCountdownCarouselState
    extends State<DashboardCountdownCarousel> {
  late final PageController _pageController;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardCountdownState(
      pageController: _pageController,
      currentPage: _currentPage,
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: const [
                CountdownDashboardCard(),
                DashboardCalendarPage(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: List.generate(
              2,
                  (index) => AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                width: _currentPage == index
                    ? 18
                    : 8,
                height: 8,
                margin:
                const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(999),
                  color: _currentPage == index
                      ? Theme.of(context)
                      .colorScheme
                      .primary
                      : Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: .35),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}