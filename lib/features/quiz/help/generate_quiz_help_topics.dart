import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Generate Quiz screen
/// (`lib/features/quiz/screens/generate_quiz_screen.dart`). Anchors wrap
/// the `StudyMaterialsCard`, `QuizConfigurationCard`, and destination
/// `Card` directly where they're built in that screen. The configuration
/// anchor simply isn't mounted in Quick Quiz mode (that card is skipped
/// entirely), which the help system already falls back gracefully from --
/// no preview-state plumbing needed.
List<HelpTopic> generateQuizHelpTopics() {
  return const [
    HelpTopic(
      id: 'study-materials',
      title: 'Choosing Study Materials',
      steps: [
        HelpStep(
          description:
              'Pick the Lecture Notes and Past Year Questions you want '
              'this quiz generated from. You can select more than one of '
              'each -- ScholarMind uses all of it together as source '
              'material.',
          anchorId: 'study-materials-card',
        ),
      ],
    ),
    HelpTopic(
      id: 'quiz-configuration',
      title: 'Quiz Configuration',
      steps: [
        HelpStep(
          description:
              'Fine-tune how the quiz is generated here: difficulty, the '
              'range of Bloom\'s levels (how much recall vs. deeper '
              'reasoning it demands), and which question types to '
              'include. Starting a "Quick Quiz" from the library skips '
              'this card entirely and generates with sensible defaults.',
          anchorId: 'configuration-card',
        ),
      ],
    ),
    HelpTopic(
      id: 'destination-folder',
      title: 'Destination Folder',
      steps: [
        HelpStep(
          description:
              'This is the folder the finished quiz will be saved into. '
              'Tap "Change" to pick a different one from your library.',
          anchorId: 'destination-folder-card',
        ),
      ],
    ),
  ];
}
