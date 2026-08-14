import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Question Overview screen
/// (`lib/features/quiz/screens/quiz_question_overview_screen.dart`),
/// pushed from the Quiz Viewer's "Questions" button. Anchors wrap only
/// the first row in the list -- every row is built by the same
/// `ListView.separated`, and (unlike the viewer's all-at-once `Column`)
/// only a handful are actually laid out at a time, but the first is
/// always among them, so it's the reliable, always-mounted anchor.
List<HelpTopic> quizQuestionOverviewHelpTopics() {
  return const [
    HelpTopic(
      id: 'jump-to-question',
      title: 'Jumping to a Question',
      steps: [
        HelpStep(
          description:
              'Tap any question here to go straight to it in the quiz -- '
              'no need to scroll or swipe through everything in between.',
          anchorId: 'question-row-first',
        ),
      ],
    ),
    HelpTopic(
      id: 'status-badges',
      title: 'Status Badges',
      steps: [
        HelpStep(
          description:
              'Each question can show a badge for its current status: '
              '"Not Important" means it\'s flagged and excluded from '
              'grading, "Guess" means you marked your answer as not '
              'confident, and "Review" means you asked to come back to '
              'it later. The icon on the left also shows at a glance '
              'whether a question has been answered yet.',
          anchorId: 'question-row-first',
        ),
      ],
    ),
  ];
}
