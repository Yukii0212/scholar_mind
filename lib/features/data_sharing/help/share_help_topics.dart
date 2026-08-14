import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// pageId shared by the Share screen
/// (`lib/features/data_sharing/screens/share_screen.dart`) and the QR view
/// it embeds (`lib/features/data_sharing/widgets/screen/share/share_qr_view.dart`),
/// so anchors registered from inside that child widget resolve against the
/// same [HelpAnchorRegistry] the screen's [HelpMenuButton] reads from.
const shareScreenHelpPageId = 'export-share';

/// Help topics for the Share screen. Anchors: `generate-button` and
/// `view-tabs` live in `share_screen.dart`; `qr-save-button` and
/// `qr-share-button` live in `share_qr_view.dart`. The QR/Save/Share
/// anchors only exist once the QR tab is showing, so steps that target them
/// switch to that tab first via [setSelectedTab].
List<HelpTopic> shareHelpTopics({
  required void Function(int) setSelectedTab,
}) {
  return [
    HelpTopic(
      id: 'how-sharing-works',
      title: 'How sharing works',
      steps: [
        const HelpStep(
          description:
              'Exporting bundles the study materials you selected into one '
              'shareable file. Anyone with ScholarMind can import it using '
              'the QR code or link you generate here.',
          scrimOpacity: HelpStep.lightScrim,
        ),
        const HelpStep(
          description:
              'Pick how long the link should stay valid, then tap here to '
              'generate a shareable link and QR code for your selection.',
          anchorId: 'generate-button',
        ),
        HelpStep(
          description:
              'Switch between a QR code (great for scanning in person) and '
              'a link (great for sending online) — both point to the same '
              'shared file.',
          anchorId: 'view-tabs',
          beforeShow: () async => setSelectedTab(0),
        ),
        const HelpStep(
          description:
              'Every link you generate — and how many times it\'s been '
              'imported — is saved here so you can find or revoke it '
              'later.',
          anchorId: 'shared-links-button',
        ),
      ],
    ),
    HelpTopic(
      id: 'save-or-share-your-qr-code',
      title: 'Save or share your QR code',
      steps: [
        HelpStep(
          description: 'Save the QR code as an image to your gallery.',
          anchorId: 'qr-save-button',
          beforeShow: () async => setSelectedTab(0),
        ),
        HelpStep(
          description:
              'Or share the QR code image directly through any app — '
              'messaging, email, and so on.',
          anchorId: 'qr-share-button',
          beforeShow: () async => setSelectedTab(0),
        ),
      ],
    ),
  ];
}
