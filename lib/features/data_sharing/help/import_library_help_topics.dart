import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Import Materials screen
/// (`lib/features/data_sharing/screens/import_library_screen.dart`).
/// Anchors live in that same file: `import-input-field`, `scan-qr-button`
/// (in the AppBar), and `import-button`.
List<HelpTopic> importLibraryHelpTopics() {
  return [
    const HelpTopic(
      id: 'importing-shared-materials',
      title: 'Importing shared materials',
      steps: [
        HelpStep(
          description:
              'Paste a ScholarMind share link or share ID here, or tap the '
              'QR icon above to scan one with your camera instead.',
          anchorId: 'import-input-field',
        ),
        HelpStep(
          description:
              'Scans a share QR code with your camera and fills this field '
              'in automatically.',
          anchorId: 'scan-qr-button',
        ),
        HelpStep(
          description:
              'Tap Import to fetch what\'s in the share. You\'ll get to '
              'review and deselect items before anything is added to your '
              'library.',
          anchorId: 'import-button',
        ),
      ],
    ),
  ];
}
