import 'package:flutter/material.dart';

import 'swipe_card_item.dart';
import 'swipe_card_selector.dart';

class SwipeCards extends StatefulWidget {
  const SwipeCards({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onPageChanged,
  });

  final List<SwipeCardItem> items;

  final int initialIndex;

  final ValueChanged<int>? onPageChanged;

  @override
  State<SwipeCards> createState() =>
      _SwipeCardsState();
}

class _SwipeCardsState
    extends State<SwipeCards> {

  late final PageController
  _pageController;

  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex =
        widget.initialIndex;

    _pageController =
        PageController(
          initialPage:
          widget.initialIndex,
        );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showSelector() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SwipeCardSelector(
          items: widget.items,
          currentIndex: _currentIndex,
          onSelected: (index) {
            _pageController.animateToPage(
              index,
              duration:
              const Duration(
                milliseconds: 300,
              ),
              curve: Curves.easeInOut,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final current =
    widget.items[_currentIndex];

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [

        Row(
          children: [

            Icon(current.icon),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                current.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),
            ),

            IconButton(
              onPressed:
              _showSelector,
              icon: const Icon(
                Icons.view_headline,
              ),
              tooltip:
              'Browse Analytics',
            ),
          ],
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 420,
          child: PageView.builder(
            controller:
            _pageController,

            onPageChanged:
                (index) {

              setState(() {
                _currentIndex =
                    index;
              });

              widget.onPageChanged
                  ?.call(index);
            },

            itemCount:
            widget.items.length,

            itemBuilder:
                (
                context,
                index,
                ) {

              return AnimatedPadding(
                duration:
                const Duration(
                  milliseconds: 250,
                ),

                curve:
                Curves.easeOut,

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 4,
                ),

                child:
                widget
                    .items[index]
                    .child,
              );
            },
          ),
        ),
      ],
    );
  }
}