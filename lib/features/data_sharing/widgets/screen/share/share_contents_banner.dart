import 'package:flutter/material.dart';

import '../../../domain/models/share/share_result.dart';
import '../../../services/share_resource_summary.dart';

/// "Contains: 12 notes, 2 folders" — shown wherever a share link's QR/link
/// is displayed, so it's answered without the user having to guess what
/// study material a link actually exports.
class ShareContentsBanner extends StatelessWidget {
  const ShareContentsBanner({super.key, required this.share});

  final ShareResult share;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contains',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  describeResourceCounts(share.resourceCounts),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
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
