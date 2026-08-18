import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Quiz Library screen
/// (`lib/features/quiz/screens/quiz_library_screen.dart`). This screen has
/// no local AppBar -- it's a bottom-nav shell tab, so its `HelpMenuButton`
/// is wired up centrally in `lib/features/help/help_route_topics.dart`
/// rather than in this file. Anchors live directly in
/// quiz_library_screen.dart: the section `SegmentedButton`, the
/// floating "+" `SpeedDial`, and the "Flagged Questions" button (only
/// shown at the library root) -- all always present, so the tutorial
/// works even for a brand-new user with no quizzes yet.
List<HelpTopic> quizLibraryHelpTopics() {
  return const [
    HelpTopic(
      id: 'library-tabs',
      title: 'Continue, Library, and Trash',
      steps: [
        HelpStep(
          description:
              'These three tabs switch what you\'re looking at: '
              '"Continue" shows quizzes you\'ve started but not finished, '
              '"Library" is every quiz organized into folders, and "Trash" '
              'holds anything you\'ve deleted.',
          anchorId: 'section-tabs',
        ),
      ],
    ),
    HelpTopic(
      id: 'create-quiz-menu',
      title: 'Creating a Quiz or Folder',
      steps: [
        HelpStep(
          description:
              'Tap this button to create something new: "New Quiz" walks '
              'you through picking study materials and configuring '
              'difficulty, Bloom\'s levels, and question types; "Quick '
              'Quiz" skips that configuration step entirely and generates '
              'straight from your study materials using sensible '
              'defaults; and "New Folder" lets you organize your library.',
          anchorId: 'quiz-fab',
        ),
      ],
    ),
    HelpTopic(
      id: 'flagged-questions',
      title: 'Flagged Questions',
      steps: [
        HelpStep(
          description:
              'Questions you\'ve marked "Not Important" on past quizzes '
              'show up here. ScholarMind uses this list to steer future '
              'quizzes away from similar questions.',
          anchorId: 'flagged-questions-button',
        ),
      ],
    ),
  ];
}
