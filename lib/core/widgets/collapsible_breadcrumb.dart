import 'package:flutter/material.dart';

/// A horizontally-scrolling breadcrumb trail that collapses long paths
/// (Home / … / second-to-last / last) instead of wrapping onto multiple
/// lines and eating vertical space.
class CollapsibleBreadcrumb extends StatelessWidget {
  const CollapsibleBreadcrumb({
    super.key,
    required this.homeLabel,
    required this.homeIcon,
    required this.segments,
    required this.onPressed,
    this.maxVisibleSegments = 2,
  });

  final String homeLabel;
  final IconData homeIcon;
  final List<String> segments;

  /// Called with the segment index, or -1 for the home crumb.
  final ValueChanged<int> onPressed;

  final int maxVisibleSegments;

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    final collapsed = segments.length > maxVisibleSegments;

    final visibleIndices = collapsed
        ? [
      for (var i = segments.length - maxVisibleSegments;
      i < segments.length;
      i++)
        i,
    ]
        : [
      for (var i = 0; i < segments.length; i++) i,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: segments.isEmpty
                ? null
                : () => onPressed(-1),
            icon: Icon(homeIcon, size: 18),
            label: Text(homeLabel),
          ),
          if (collapsed) ...[
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: mutedColor,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child: Text('…'),
            ),
          ],
          for (final index in visibleIndices) ...[
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: mutedColor,
            ),
            TextButton(
              onPressed: () => onPressed(index),
              child: Text(segments[index]),
            ),
          ],
        ],
      ),
    );
  }
}
