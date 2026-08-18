import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Countdown tab
/// (`lib/features/countdown/screens/countdown_screen.dart`, `pageId:
/// '/countdown'`). Anchors live directly in that screen: the "New
/// Countdown" FAB and the three summary tiles (Active / Urgent / Exams) are
/// always on screen, even for a brand-new user with no countdowns yet, so
/// those steps spotlight the real chrome.
///
/// The "managing a countdown" topic below is the exception — the actions it
/// describes (Mark as Completed, Edit, Hide, Delete) only exist inside a
/// countdown card's expanded panel
/// (`lib/features/countdown/widgets/countdown_card.dart`), which isn't in
/// the widget tree at all until a countdown exists and the user taps to
/// expand it. Rather than add a preview-state provider just to fake that
/// for the tutorial, those steps omit `anchorId` and fall back to a
/// centered, non-spotlit bubble.
List<HelpTopic> countdownHelpTopics() {
  return const [
    HelpTopic(
      id: 'creating-a-countdown',
      title: 'How do I add a countdown?',
      steps: [
        HelpStep(
          description:
              'Tap the + button, then choose "New Countdown" to track an '
              'exam, assignment, quiz, or any other deadline.',
          anchorId: 'new-countdown-fab',
        ),
      ],
    ),
    HelpTopic(
      id: 'summary-counts',
      title: 'What do the Active, Urgent, and Exams numbers mean?',
      steps: [
        HelpStep(
          description:
              '"Active" counts every countdown that isn\'t completed or '
              'hidden yet — your current list of upcoming deadlines.',
          anchorId: 'summary-active-tile',
        ),
        HelpStep(
          description:
              '"Urgent" is the subset of Active countdowns due within the '
              'next 3 days, so the ones that need attention soonest stand '
              'out.',
          anchorId: 'summary-urgent-tile',
        ),
        HelpStep(
          description:
              '"Exams" counts active Midterm and Final Exam countdowns '
              'specifically, separate from assignments and other '
              'deadlines.',
          anchorId: 'summary-exams-tile',
        ),
      ],
    ),
    HelpTopic(
      id: 'managing-a-countdown',
      title: 'How do I complete, hide, or delete a countdown?',
      steps: [
        HelpStep(
          description:
              'Tap any countdown card to expand it and reveal its '
              'actions: mark it completed, edit it, hide it, or delete '
              'it.',
        ),
        HelpStep(
          description:
              '"Mark as Completed" moves it from Active to the Completed '
              'list once you\'re done — tap "Mark as Active" the same way '
              'to undo it.',
        ),
        HelpStep(
          description:
              '"Hide" moves a countdown into a separate Hidden list '
              'without deleting it — useful for something you don\'t want '
              'cluttering your view but might need again. "Unhide" brings '
              'it straight back, and hiding works on both active and '
              'completed countdowns.',
        ),
        HelpStep(
          description:
              '"Delete" removes a countdown permanently, and asks you to '
              'confirm first. Unlike Hide, there\'s no way to undo it.',
        ),
      ],
    ),
  ];
}
