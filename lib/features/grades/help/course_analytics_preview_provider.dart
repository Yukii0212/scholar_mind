import 'package:flutter_riverpod/flutter_riverpod.dart';

/// While true, the Current Standing card shows one illustrative, static
/// "Projected Score" block instead of omitting it entirely — so the "What
/// does 'Projected Score' mean?" help step always has something to
/// highlight, even for a course with no Expected values entered yet
/// (exactly when that explanation matters most). A course that already has
/// Expected entries ignores this and shows its own real projected score.
/// Set by that step's `beforeShow`, cleared when the tutorial closes.
final courseAnalyticsProjectedScorePreviewProvider = StateProvider<bool>(
  (ref) => false,
);
