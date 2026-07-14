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
    extends State<SwipeCards>
    with TickerProviderStateMixin {

  static const int _virtualMiddle = 1000000;

  late final PageController
  _pageController;

  late int _virtualIndex;

  late int _currentIndex;

  bool _showSwipeHint = true;

  @override
  void initState() {
    super.initState();

    _virtualIndex =
        _virtualMiddle +
            widget.initialIndex;

    _currentIndex =
        widget.initialIndex;

    _pageController =
        PageController(
          initialPage: _virtualIndex,
          viewportFraction: 0.90,
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

            final target =
                _virtualIndex -
                    _currentIndex +
                    index;

            _pageController.animateToPage(
              target,
              duration:
              const Duration(
                milliseconds: 300,
              ),
              curve:
              Curves.easeInOut,
            );
          },
        );
      },
    );
  }

  Widget _buildIndicator(
      BuildContext context) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
            (index) {
          final selected =
              index == _currentIndex;

          return AnimatedContainer(
            duration:
            const Duration(
              milliseconds: 250,
            ),
            margin:
            const EdgeInsets
                .symmetric(
              horizontal: 4,
            ),
            width:
            selected ? 18 : 8,
            height: 8,
            decoration:
            BoxDecoration(
              color: selected
                  ? Theme.of(
                  context)
                  .colorScheme
                  .primary
                  : Theme.of(
                  context)
                  .dividerColor,
              borderRadius:
              BorderRadius
                  .circular(99),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current =
    widget.items[_currentIndex];

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment
          .stretch,
      children: [

        Row(
          children: [

            Icon(current.icon),

            const SizedBox(
                width: 12),

            Expanded(
              child: Text(
                current.title,
                style: Theme.of(
                    context)
                    .textTheme
                    .titleLarge,
              ),
            ),

            Text(
              '${_currentIndex + 1} / ${widget.items.length}',
              style: Theme.of(
                  context)
                  .textTheme
                  .bodyMedium,
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

        const SizedBox(
            height: 8),

        _buildIndicator(context),

        const SizedBox(
            height: 8),

        AnimatedOpacity(
          opacity:
          _showSwipeHint
              ? 1
              : 0,
          duration:
          const Duration(
            milliseconds: 350,
          ),
          child: const Padding(
            padding:
            EdgeInsets.only(
              bottom: 12,
            ),
            child: Text(
              '← Swipe for more analytics →',
              textAlign:
              TextAlign.center,
            ),
          ),
        ),

        AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 250,
          ),
          curve:
          Curves.easeInOut,
          height: current.height,
          child:
          PageView.builder(
            controller:
            _pageController,

            onPageChanged:
                (virtualIndex) {

              setState(() {

                _virtualIndex =
                    virtualIndex;

                _currentIndex =
                    virtualIndex %
                        widget.items.length;

                _showSwipeHint =
                false;
              });

              widget.onPageChanged
                  ?.call(
                _currentIndex,
              );
            },

            itemBuilder:
                (
                context,
                virtualIndex,
                ) {

              final index =
                  virtualIndex %
                      widget.items.length;

              return Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 6,
                ),
                child:
                AnimatedScale(
                  duration:
                  const Duration(
                    milliseconds:
                    250,
                  ),
                  curve:
                  Curves.easeOut,
                  scale:
                  index ==
                      _currentIndex
                      ? 1
                      : 0.96,
                  child: LayoutBuilder(
                    builder: (
                        context,
                        constraints,
                        ) {
                      return SingleChildScrollView(
                        physics:
                        const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(
                            minHeight:
                            constraints.maxHeight,
                          ),
                          child: widget
                              .items[index]
                              .child,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}