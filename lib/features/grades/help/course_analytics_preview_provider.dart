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

/// Same idea as [courseAnalyticsProjectedScorePreviewProvider], for the
/// Required Score Calculator card: while true, it shows one illustrative,
/// static example instead of its "more information required" message, so
/// the "What does the 'Required Score Calculator' show?" help step always
/// has real-looking numbers to point at, even for a course with no
/// assessments entered yet. A course that can already calculate a real
/// required score ignores this and shows its own real numbers.
final courseAnalyticsRequiredScorePreviewProvider = StateProvider<bool>(
  (ref) => false,
);
