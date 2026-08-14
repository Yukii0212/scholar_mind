import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Flashcards library tab
/// (`lib/features/flashcards/screens/flashcard_library_screen.dart`).
/// This screen has no local AppBar — it's a shell bottom-nav tab, so its
/// [HelpMenuButton] is registered centrally in
/// `lib/features/help/help_route_topics.dart` for route `/flashcards`
/// rather than wired up here.
///
/// Anchors live directly in `flashcard_library_screen.dart`:
/// `section-tabs` on the Continue/Library/Trash [SegmentedButton] and
/// `fab-menu` on the `+` [SpeedDial]. Both are always-present chrome, so
/// these topics work even for a brand-new user with no flashcard sets yet.
List<HelpTopic> flashcardLibraryHelpTopics() {
  return [
    const HelpTopic(
      id: 'library-tabs',
      title: 'The Continue, Library, and Trash tabs',
      steps: [
        HelpStep(
          description:
              '"Continue" lists flashcard sets you\'ve started studying but '
              "haven't finished — pick one up where you left off.",
          anchorId: 'section-tabs',
        ),
        HelpStep(
          description:
              '"Library" is where all your sets and folders live. These '
              'tabs stay visible even while you\'re browsing into a folder, '
              'so you can always jump back to Continue or Trash.',
          anchorId: 'section-tabs',
        ),
        HelpStep(
          description:
              '"Trash" holds deleted flashcard sets. You can restore or '
              'permanently remove them from there.',
          anchorId: 'section-tabs',
        ),
      ],
    ),
    const HelpTopic(
      id: 'add-menu',
      title: 'What can you do from the + button?',
      steps: [
        HelpStep(
          description: 'Tap the + button for four ways to add to your library: '
              '"Generate Flashcards" walks you through picking materials '
              'and configuring difficulty, Bloom\'s level, and card count '
              'before the AI generates a set.',
          anchorId: 'fab-menu',
        ),
        HelpStep(
          description: '"Quick Flashcard" is the fast path — pick your study '
              'materials and generate immediately, skipping the '
              'configuration step entirely.',
          anchorId: 'fab-menu',
        ),
        HelpStep(
          description:
              '"Create Set" makes an empty set you fill in by hand, with '
              'no AI involved. "New Folder" adds a folder here to keep '
              'your sets organized.',
          anchorId: 'fab-menu',
        ),
      ],
    ),
  ];
}
