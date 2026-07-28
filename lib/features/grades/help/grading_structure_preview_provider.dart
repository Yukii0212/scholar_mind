import 'package:flutter_riverpod/flutter_riverpod.dart';

/// While true, the grading structure editor shows one illustrative,
/// non-interactive example component (with an example subcomponent)
/// instead of its real empty state — so the "What is a Component?" /
/// "What is a Subcomponent?" help tutorial always has something concrete
/// to highlight, even on a brand-new structure with nothing in it yet
/// (exactly when that explanation matters most). A structure that already
/// has real components ignores this entirely and just highlights the
/// user's own first one. Set by those steps' `beforeShow`, cleared when
/// the tutorial closes.
final gradingStructureHelpPreviewProvider = StateProvider<bool>(
  (ref) => false,
);
