import '../home/help/home_dashboard_help_topics.dart';
import '../home/help/standing_chip_preview_provider.dart';
import 'domain/help_topic.dart';

/// Help topics for pages reachable through the shared shell AppBar
/// (`lib/features/home/screens/home_screen.dart`), keyed by
/// `GoRouterState.matchedLocation`. Screens with their own local AppBar
/// (e.g. Grades' course/semester detail screens) wire up [HelpMenuButton]
/// directly instead of registering here — see `lib/features/grades/help/`.
///
/// Note: `matchedLocation` for parameterised routes (e.g.
/// `/import/share/:shareId`) includes the interpolated value, so a future
/// topic set for a route like that needs a prefix match rather than exact
/// equality. Not needed yet since no such route has topics below.
List<HelpTopic> helpTopicsForRoute(
  String location, {
  required void Function(StandingPreview?) setStandingPreview,
}) {
  switch (location) {
    case '/home':
      return homeDashboardHelpTopics(setStandingPreview: setStandingPreview);
    default:
      return const [];
  }
}
