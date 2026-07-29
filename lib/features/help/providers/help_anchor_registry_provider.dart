import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the [GlobalKey] for each help anchor on a single page, created
/// lazily as [HelpAnchor] widgets register themselves. Scoped per pageId
/// via [helpAnchorRegistryProvider] and torn down automatically once the
/// page unmounts, so anchor ids can be reused freely across pages.
class HelpAnchorRegistry {
  final Map<String, GlobalKey> _keys = {};

  GlobalKey keyFor(String anchorId) =>
      _keys.putIfAbsent(anchorId, () => GlobalKey());
}

final helpAnchorRegistryProvider =
    Provider.autoDispose.family<HelpAnchorRegistry, String>(
  (ref, pageId) => HelpAnchorRegistry(),
);
