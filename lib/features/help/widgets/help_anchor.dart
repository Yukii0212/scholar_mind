import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/help_anchor_registry_provider.dart';

/// Wraps a widget so the help system can find and spotlight it later.
///
/// Wrap this tightly around the exact element a [HelpTopic] should
/// highlight (e.g. just a value block, not the whole card it lives in) so
/// the spotlight cutout stays precise.
class HelpAnchor extends ConsumerWidget {
  const HelpAnchor({
    super.key,
    required this.pageId,
    required this.anchorId,
    required this.child,
  });

  final String pageId;
  final String anchorId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(helpAnchorRegistryProvider(pageId));

    return KeyedSubtree(
      key: registry.keyFor(anchorId),
      child: child,
    );
  }
}
