import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Quiz Viewer screen
/// (`lib/features/quiz/screens/quiz_viewer_screen.dart`).
///
/// Anchors:
/// - `questions-overview-button` wraps the "Questions" AppBar action,
///   always present regardless of navigation style.
/// - `not-important-flag` wraps only the *first* question's "Not
///   important" checkbox, not every question's -- in scroll mode every
///   question card is built at once (see the comment on `_buildScrollBody`
///   about why it's a plain `Column`, not a culled `ListView`), so
///   anchoring every one of them under the same id would register more
///   than one widget against the same `GlobalKey` simultaneously and
///   crash. The first question is always present in both scroll and
///   swipe mode's initial page, so it stays a reliable anchor.
/// - `submit-quiz-button` wraps the Submit Quiz button in both
///   `_buildScrollBody` and `_buildSwipeBody` -- safe because only one of
///   those two bodies (and, within swipe mode, only one of the
///   Next/Submit buttons) is ever actually built at a time.
List<HelpTopic> quizViewerHelpTopics() {
  return const [
    HelpTopic(
      id: 'navigating-questions',
      title: 'Moving Between Questions',
      steps: [
        HelpStep(
          description:
              'You can move between questions two ways: scroll through '
              'all of them in one list, or swipe left/right one question '
              'at a time. You picked your style when you started this '
              'quiz -- change it anytime from your profile settings.',
        ),
        HelpStep(
          description:
              'Tap "Questions" to see every question at a glance and '
              'jump straight to any one of them.',
          anchorId: 'questions-overview-button',
        ),
      ],
    ),
    HelpTopic(
      id: 'not-important-flag',
      title: 'Flagging a Question "Not Important"',
      steps: [
        HelpStep(
          description:
              'Check this if a question is off-topic or trivial. It '
              'won\'t count toward your score, and ScholarMind will try '
              'to avoid asking similar questions in future quizzes.',
          anchorId: 'not-important-flag',
        ),
      ],
    ),
    HelpTopic(
      id: 'submitting-quiz',
      title: 'Submitting Your Quiz',
      steps: [
        HelpStep(
          description:
              'When you\'re done, tap Submit Quiz. You don\'t need to '
              'answer every question first -- you can still review and '
              'adjust flags afterward from the results screen.',
          anchorId: 'submit-quiz-button',
        ),
      ],
    ),
  ];
}
