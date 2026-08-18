import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Generate Flashcards screen
/// (`lib/features/flashcards/screens/generate_flashcards_screen.dart`).
/// Anchors live directly in that screen: `study-materials-card` on the
/// [StudyMaterialsCard], `configuration-card` on the
/// [FlashcardConfigurationCard] (only present outside Quick Flashcard mode
/// -- the step still works when it's missing, it just falls back to a
/// plain centered bubble), and `destination-picker` on the Destination
/// [Card]. All three are always-present chrome for a normal (non-quick)
/// visit to this screen, so these topics work even before any materials
/// are picked.
List<HelpTopic> generateFlashcardsHelpTopics() {
  return [
    const HelpTopic(
      id: 'study-materials',
      title: 'Selecting study materials',
      steps: [
        HelpStep(
          description:
              'Pick the lecture notes and past year questions you want '
              'flashcards generated from. You can mix both, and add more '
              'later from the "Manage" option once some are selected.',
          anchorId: 'study-materials-card',
        ),
      ],
    ),
    const HelpTopic(
      id: 'configuration',
      title: "Difficulty, Bloom's level, and card count",
      steps: [
        HelpStep(
          description:
              'This card controls how many cards are generated, how hard '
              "they are, and which Bloom's taxonomy levels they target -- "
              'along with an Additional Instructions panel below it for '
              'optional guidance and tags. "Quick Flashcard" from the '
              'library\'s + menu skips this card and that panel entirely, '
              'generating straight from your selected materials with '
              'default settings.',
          anchorId: 'configuration-card',
        ),
      ],
    ),
    const HelpTopic(
      id: 'destination',
      title: 'Choosing a destination folder',
      steps: [
        HelpStep(
          description:
              'Generated sets are saved to "My Flashcards" by default. Tap '
              '"Change" to pick a different folder before generating.',
          anchorId: 'destination-picker',
        ),
      ],
    ),
  ];
}
