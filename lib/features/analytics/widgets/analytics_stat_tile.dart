import 'package:flutter/material.dart';

import '../../../core/theme/app_design.dart';

class AnalyticsStatTile extends StatelessWidget {
  const AnalyticsStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return ScholarPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ScholarIconBadge(icon: icon, size: 44, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lays out stat tiles two-per-row without GridView's fixed aspect ratio --
/// GridView.count forces every cell into the same box-shaped height
/// regardless of content, which overflowed as soon as a tile's value/label
/// needed more vertical room than that box allowed (e.g. on a narrower
/// phone width). Rows here size to their own content instead, so there's
/// nothing to overflow.
class AnalyticsStatGrid extends StatelessWidget {
  const AnalyticsStatGrid({super.key, required this.tiles});

  final List<AnalyticsStatTile> tiles;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var i = 0; i < tiles.length; i += 2) {
      final rowTiles = [
        tiles[i],
        if (i + 1 < tiles.length) tiles[i + 1],
      ];

      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < rowTiles.length; j++) ...[
                Expanded(child: rowTiles[j]),
                if (j != rowTiles.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        ),
      );

      if (i + 2 < tiles.length) rows.add(const SizedBox(height: 10));
    }

    return Column(children: rows);
  }
}
