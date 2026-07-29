import 'package:flutter/material.dart';

import '../../theme/app_design.dart';
import 'swipe_card_item.dart';

/// Shows one of [items] at a time, at its natural full height, switched via
/// a labeled bar beneath it (tap a label, or swipe the bar) — matching the
/// dashboard's countdown/calendar switcher
/// (`lib/features/home/widgets/countdown/dashboard_countdown_carousel.dart`).
///
/// Deliberately does not clip or collapse a page's content: an earlier
/// version showed a fixed-height preview you tapped to expand into a full
/// screen, which silently hid overflowing content instead of surfacing it,
/// and made programmatically bringing a specific element into view (for
/// the help tutorial) fight several layers of carousel-internal state.
/// Showing the real content directly avoids both problems.
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
  State<SwipeCards> createState() => SwipeCardsState();
}

class SwipeCardsState extends State<SwipeCards> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant SwipeCards oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialIndex != widget.initialIndex &&
        widget.initialIndex != _currentIndex) {
      setState(() => _currentIndex = widget.initialIndex);
    }
  }

  /// Switches directly to [index]. Used by the help tutorial to bring a
  /// specific card into view before spotlighting something inside it.
  void showPage(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    widget.onPageChanged?.call(_currentIndex);
  }

  void _switchBy(int delta) {
    final next =
        (_currentIndex + delta + widget.items.length) % widget.items.length;
    showPage(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ViewSwitchBar(
          items: widget.items,
          currentIndex: _currentIndex,
          onSwipe: _switchBy,
          onSelected: showPage,
        ),
        const SizedBox(height: 14),
        GestureDetector(
          // Lets you swipe anywhere on the card itself, not just the
          // switch bar above — the card's own content has no competing
          // horizontal gesture, so this is unambiguous.
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;

            if (velocity < -100) {
              _switchBy(1);
            } else if (velocity > 100) {
              _switchBy(-1);
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
                return FadeTransition(opacity: animation, child: child);
              },
              child: KeyedSubtree(
                key: ValueKey(_currentIndex),
                child: widget.items[_currentIndex].child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewSwitchBar extends StatelessWidget {
  const _ViewSwitchBar({
    required this.items,
    required this.currentIndex,
    required this.onSwipe,
    required this.onSelected,
  });

  final List<SwipeCardItem> items;
  final int currentIndex;
  final ValueChanged<int> onSwipe;
  final ValueChanged<int> onSelected;

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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: palette.panelStrong.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.stroke.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < items.length; i++)
              _SwitchBarItem(
                item: items[i],
                selected: i == currentIndex,
                onTap: () => onSelected(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwitchBarItem extends StatelessWidget {
  const _SwitchBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final SwipeCardItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : palette.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              item.title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
