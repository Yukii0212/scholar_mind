import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Google Classroom import screen
/// (`lib/features/notes/screens/google_classroom_import_screen.dart`).
///
/// Anchors:
/// - `classroom-browser` — the whole `IgnorePointer`/`RefreshIndicator`
///   body, always present regardless of loading/error/data state.
/// - `classroom-tabs` — the "Active Classes" / "Hidden Classes" segmented
///   control. It only renders once courses have loaded and at least one is
///   visible in the current tab, so a user with zero Classroom courses
///   simply gets this step's fallback centered bubble instead — no preview
///   state needed to keep it useful.
///
/// The "Import" button in the app bar only exists once at least one file is
/// checked, so — same reasoning as the Google Drive import topics — the
/// step describing it stays a plain centered bubble rather than mocking a
/// selection just to anchor it.
List<HelpTopic> googleClassroomImportHelpTopics() {
  return const [
    HelpTopic(
      id: 'classroom-import-flow',
      title: 'Importing from Google Classroom',
      steps: [
        HelpStep(
          description:
              'Your Google Classroom courses are listed here as cards. '
              'Tap a course to expand it and see its materials.',
          anchorId: 'classroom-browser',
          scrimOpacity: HelpStep.lightScrim,
        ),
        HelpStep(
          description:
              '"Active Classes" shows your current courses. "Hidden '
              'Classes" holds any you\'ve hidden yourself, plus courses '
              'Google Classroom marks as archived.',
          anchorId: 'classroom-tabs',
        ),
        HelpStep(
          description:
              'Inside an expanded course, check the box next to a file to '
              'select it for import.',
        ),
        HelpStep(
          description:
              'Once you\'ve selected at least one file, an Import button '
              'appears in the top-right corner showing how many you\'ve '
              'picked. Tap it to bring those files into this folder in '
              'ScholarMind.',
        ),
      ],
    ),
  ];
}
