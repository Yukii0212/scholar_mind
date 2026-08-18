import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Import Preview screen
/// (`lib/features/data_sharing/screens/import_preview_screen.dart`).
/// Anchors live in that same file: `select-all-button` and
/// `import-selected-button`.
List<HelpTopic> importPreviewHelpTopics() {
  return [
    const HelpTopic(
      id: 'review-before-importing',
      title: 'Review before importing',
      steps: [
        HelpStep(
          description:
              'Everything in the shared file is listed here, selected by '
              'default. Uncheck anything you don\'t want to bring into '
              'your library.',
          scrimOpacity: HelpStep.lightScrim,
        ),
        HelpStep(
          description: 'Reselect everything at once.',
          anchorId: 'select-all-button',
        ),
        HelpStep(
          description:
              'Adds only the checked items to your library — nothing is '
              'imported until you tap this.',
          anchorId: 'import-selected-button',
        ),
      ],
    ),
  ];
}
