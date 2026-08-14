import '../../help/domain/help_topic.dart';
import '../../help/domain/help_step.dart';

/// Help topics for the Export Cart screen
/// (`lib/features/data_sharing/screens/export_cart_screen.dart`).
/// Anchors live in that same file: `cart-header` on the item-count header
/// and `export-button` on the bottom "Export" button.
List<HelpTopic> exportCartHelpTopics() {
  return [
    const HelpTopic(
      id: 'reviewing-your-export',
      title: 'Reviewing your export',
      steps: [
        HelpStep(
          description:
              'This is everything you selected, grouped by category. Swipe '
              'an item to remove it, or use Clear All to start over.',
          anchorId: 'cart-header',
        ),
        HelpStep(
          description:
              'When you\'re happy with your selection, tap Export to '
              'bundle it into a shareable link and QR code.',
          anchorId: 'export-button',
        ),
      ],
    ),
  ];
}
