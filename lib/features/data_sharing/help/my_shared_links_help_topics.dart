import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the My Shared Links screen
/// (`lib/features/data_sharing/screens/my_shared_links_screen.dart`).
/// The list of links (and each link's revoke menu) is entirely
/// data-dependent, so these steps don't anchor to anything — they stay as
/// centered bubbles that read correctly whether or not the user has any
/// active links yet.
List<HelpTopic> mySharedLinksHelpTopics() {
  return [
    const HelpTopic(
      id: 'managing-your-links',
      title: 'Managing your shared links',
      steps: [
        HelpStep(
          description:
              'Every link you\'ve generated from the Share screen shows up '
              'here, along with how many times it\'s been imported.',
          scrimOpacity: HelpStep.lightScrim,
        ),
        HelpStep(
          description:
              'Tap a link to view its QR code and URL again, or open its '
              'menu to revoke it. Once revoked, nobody can import from it '
              'anymore — this can\'t be undone.',
          scrimOpacity: HelpStep.lightScrim,
        ),
      ],
    ),
  ];
}
