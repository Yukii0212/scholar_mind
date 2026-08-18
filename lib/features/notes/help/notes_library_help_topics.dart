import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';
import '../domain/library_enums.dart';

/// Help topics for the Notes library
/// (`lib/features/notes/screens/notes_screen.dart`), reached through the
/// shared shell AppBar (pageId `/notes`, registered centrally in
/// `lib/features/help/help_route_topics.dart`).
///
/// Anchors:
/// - `library-section-tabs` — the Library/Favorites/Archived/Trash segmented
///   control, in `lib/features/notes/widgets/library_header.dart`.
/// - `notes-fab` — the add (+) speed-dial button itself, always present
///   whenever adding is allowed, in `notes_screen.dart`.
/// - `fab-import-file` / `fab-new-note` / `fab-new-folder` (+ their
///   `-label` counterparts) — the three speed-dial options' icons and
///   labels, only mounted while the dial is open. [setFabOpen] forces it
///   open (a real, functional open — not a mocked preview) so each option
///   can be spotlighted in turn; each step's `secondaryAnchorId` extends
///   the spotlight to cover the label too, not just the icon.
/// - `library-section-tabs` steps use [setSection] to actually switch the
///   Notes screen to whichever section they're describing, so the view
///   underneath matches the narration instead of staying on Library.
///
/// - `first-folder-card` — the first folder card in the current list, in
///   `notes_screen.dart`. A brand-new user has no folders yet, so this
///   anchor isn't always mounted -- the help system's own fallback (a
///   centered, non-spotlit bubble) covers that case automatically.
List<HelpTopic> notesLibraryHelpTopics({
  required void Function(bool) setFabOpen,
  required void Function(LibrarySection) setSection,
}) {
  Future<void> openFab() async {
    setFabOpen(true);
    // Matches (with margin) flutter_speed_dial's default 150ms open
    // animation, so the anchor is measured once the button has actually
    // finished moving into place.
    await Future.delayed(const Duration(milliseconds: 260));
  }

  return [
    HelpTopic(
      id: 'library-sections',
      title: 'Library, Favorites, Archived & Trash',
      // Leaves the view on whichever section the last step showed --
      // reset back to the default so closing the tutorial mid-way (e.g.
      // on the Trash step) doesn't strand the user there.
      onDismiss: () => setSection(LibrarySection.browse),
      steps: [
        HelpStep(
          description:
              'Library is where all your active notes and folders live — '
              'this is the default view when you open Notes.',
          anchorId: 'library-section-tabs',
          beforeShow: () async => setSection(LibrarySection.browse),
        ),
        HelpStep(
          description:
              'Favorites shows folders and notes you\'ve starred, so you '
              'can jump to what you use most without digging through '
              'folders.',
          anchorId: 'library-section-tabs',
          beforeShow: () async => setSection(LibrarySection.favorites),
        ),
        HelpStep(
          description:
              'Archived holds folders you\'ve set aside without deleting '
              'them — they stay out of your main Library view until you '
              'need them again.',
          anchorId: 'library-section-tabs',
          beforeShow: () async => setSection(LibrarySection.archived),
        ),
        HelpStep(
          description:
              'Trash holds deleted notes and folders for a grace period '
              'before they\'re gone for good. Restore items one at a time, '
              'or use Restore All / Delete All to handle everything at '
              'once.',
          anchorId: 'library-section-tabs',
          beforeShow: () async => setSection(LibrarySection.trash),
        ),
      ],
    ),
    HelpTopic(
      id: 'folders',
      title: 'Working with folders',
      onDismiss: () => setFabOpen(false),
      steps: [
        HelpStep(
          description:
              'Folders help you organize notes by course, topic, or '
              'however you like. Tap the + button and choose "New Folder" '
              'to create one.',
          anchorId: 'notes-fab',
          beforeShow: () async => setFabOpen(false),
        ),
        HelpStep(
          description:
              'Tap any folder to open it. A breadcrumb trail appears at '
              'the top so you can navigate back to where you started.',
          anchorId: 'first-folder-card',
          scrimOpacity: HelpStep.lightScrim,
          beforeShow: () async => setSection(LibrarySection.browse),
        ),
      ],
    ),
    HelpTopic(
      id: 'add-menu',
      title: 'Adding notes and folders',
      onDismiss: () => setFabOpen(false),
      steps: [
        HelpStep(
          description:
              'Tap the + button to add something to the current folder — '
              'it opens three options.',
          anchorId: 'notes-fab',
          beforeShow: () async => setFabOpen(false),
        ),
        HelpStep(
          description:
              '"Import File" brings in a file from your device, Google '
              'Drive, or Google Classroom.',
          anchorId: 'fab-import-file',
          secondaryAnchorId: 'fab-import-file-label',
          beforeShow: openFab,
        ),
        HelpStep(
          description:
              '"New Note" creates a blank note you can write directly '
              'inside ScholarMind.',
          anchorId: 'fab-new-note',
          secondaryAnchorId: 'fab-new-note-label',
          beforeShow: openFab,
        ),
        HelpStep(
          description:
              '"New Folder" creates a new folder here to help keep things '
              'organized.',
          anchorId: 'fab-new-folder',
          secondaryAnchorId: 'fab-new-folder-label',
          beforeShow: openFab,
        ),
      ],
    ),
  ];
}
