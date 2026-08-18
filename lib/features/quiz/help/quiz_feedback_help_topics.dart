import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Flagged Questions screen
/// (`lib/features/quiz/screens/quiz_feedback_screen.dart`), reached from
/// the "Flagged Questions" button on the Quiz Library screen.
List<HelpTopic> quizFeedbackHelpTopics() {
  return const [
    HelpTopic(
      id: 'what-flagging-does',
      title: 'What Does Flagging Do?',
      steps: [
        HelpStep(
          description:
              'Every question you\'ve marked "Not Important" from a '
              'quiz\'s results ends up here. ScholarMind uses this list '
              'to steer future quiz generation away from similar '
              'questions, so the topics you\'ve flagged show up less '
              'often.',
        ),
      ],
    ),
    HelpTopic(
      id: 'clear-all',
      title: 'Clearing All Flags',
      steps: [
        HelpStep(
          description:
              'Tap this to remove every flagged question at once. Future '
              'quizzes will no longer avoid these topics -- use it if '
              'you want a clean slate.',
          anchorId: 'clear-all-button',
        ),
      ],
    ),
  ];
}
