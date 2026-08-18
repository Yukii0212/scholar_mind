import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Export Library screen
/// (`lib/features/data_sharing/screens/export_library_screen.dart`).
/// Anchors live in that same file: `notes-section` on the first module
/// section (always present, even before the user has any notes) and
/// `continue-button` on the bottom "Continue" button.
List<HelpTopic> exportLibraryHelpTopics() {
  return [
    const HelpTopic(
      id: 'selecting-what-to-export',
      title: 'Selecting what to export',
      steps: [
        HelpStep(
          description:
              'Browse each category below — Notes, Countdowns, Flashcards, '
              'Quizzes, and Grades — and pick the items you want to share. '
              'Exporting bundles everything you select into one shareable '
              'file.',
          anchorId: 'notes-section',
          scrimOpacity: HelpStep.lightScrim,
        ),
        HelpStep(
          description:
              'Once you\'ve picked at least one item, tap Continue to '
              'review your selection before generating a share link or QR '
              'code.',
          anchorId: 'continue-button',
        ),
      ],
    ),
  ];
}
