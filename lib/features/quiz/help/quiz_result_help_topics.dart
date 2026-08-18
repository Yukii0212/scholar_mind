import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Quiz Result screen
/// (`lib/features/quiz/screens/quiz_result_screen.dart`). The score
/// breakdown anchor wraps whichever summary card renders first (the
/// percentage card when there are objective questions, otherwise the
/// open-ended review card) -- see the wiring in that screen for how the
/// same anchor id is reused across both, mutually-exclusive positions so
/// exactly one instance of it is ever mounted.
List<HelpTopic> quizResultHelpTopics() {
  return const [
    HelpTopic(
      id: 'score-breakdown',
      title: 'Reading Your Score',
      steps: [
        HelpStep(
          description:
              'Your score breaks down by question type: multiple-choice '
              'and true/false are graded instantly, while open-ended '
              'answers get an AI review that can take a little longer -- '
              'you\'ll see "AI Review in Progress" until it\'s done.',
          anchorId: 'score-summary',
        ),
      ],
    ),
    HelpTopic(
      id: 'export-pdf',
      title: 'Exporting to PDF',
      steps: [
        HelpStep(
          description:
              'Tap this to generate a PDF of your results and share it -- '
              'handy for keeping a record or sending to someone else.',
          anchorId: 'export-pdf-button',
        ),
      ],
    ),
    HelpTopic(
      id: 'manage-not-important',
      title: 'Managing "Not Important" Flags',
      steps: [
        HelpStep(
          description:
              'Expand a question and use this button to flag it "Not '
              'Important" (excluding it from your score) or, if it\'s '
              'already flagged, to include it back in. Flagging also '
              'helps steer future quizzes away from similar questions.',
          anchorId: 'not-important-toggle',
        ),
      ],
    ),
  ];
}
