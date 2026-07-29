import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The four states `SemesterPanel`'s standing chip can show
/// (`lib/features/home/widgets/grades/semester_panel.dart`), named
/// independently of the display strings so the tutorial
/// (`lib/features/home/help/home_dashboard_help_topics.dart`) can request
/// one without hardcoding label text in two places.
enum StandingPreview { onTrack, notAchievable, needsWork, noData }

/// While non-null, the first course row's standing chip displays this
/// state instead of its real one, so the "On Track / Not Achievable /
/// Needs Work / No Data Yet" tutorial can show the state it's currently
/// explaining rather than whatever the course's real standing happens to
/// be. Set by each tutorial step's `beforeShow` and cleared when the
/// tutorial closes.
final standingChipPreviewProvider = StateProvider<StandingPreview?>(
  (ref) => null,
);
