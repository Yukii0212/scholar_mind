import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Google Drive import screen
/// (`lib/features/notes/screens/google_drive_import_screen.dart`).
///
/// The only anchor, `drive-browser`, wraps the screen's whole
/// `RefreshIndicator` body — the always-present container that shows the
/// loading spinner, the empty state, or the file/folder list depending on
/// what's loaded, so the spotlight lands somewhere sensible no matter what
/// the user's Drive currently contains. The "Import" button in the app bar
/// only exists once at least one file is checked, so rather than mock a
/// selection just to anchor it, the step that explains it is a plain
/// centered bubble that tells the user where to look for it.
List<HelpTopic> googleDriveImportHelpTopics() {
  return const [
    HelpTopic(
      id: 'drive-import-flow',
      title: 'Importing from Google Drive',
      steps: [
        HelpStep(
          description:
              'Browse your Google Drive here. Tap a folder to open it, or '
              'check the box next to a file to select it for import.',
          anchorId: 'drive-browser',
          scrimOpacity: HelpStep.lightScrim,
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
