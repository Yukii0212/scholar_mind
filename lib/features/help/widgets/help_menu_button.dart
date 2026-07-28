import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/help_topic.dart';
import '../providers/help_anchor_registry_provider.dart';
import 'help_spotlight_overlay.dart';
import 'help_topic_dialog.dart';

/// Help icon for a single page. Tapping it opens a menu of [topics] for
/// that page (identified by [pageId]); picking one either spotlights its
/// anchored widget or, for purely conceptual topics, shows a plain
/// explanation dialog. Nothing happens until the user opts in.
class HelpMenuButton extends ConsumerWidget {
  const HelpMenuButton({
    super.key,
    required this.pageId,
    required this.topics,
  });

  final String pageId;
  final List<HelpTopic> topics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (topics.isEmpty) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.help_outline_rounded),
      tooltip: 'Help',
      onPressed: () => _openMenu(context, ref),
    );
  }

  Future<void> _openMenu(BuildContext context, WidgetRef ref) async {
    final topic = await showModalBottomSheet<HelpTopic>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final topic in topics)
              ListTile(
                title: Text(topic.title),
                subtitle: Text(
                  topic.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.pop(sheetContext, topic),
              ),
          ],
        ),
      ),
    );

    if (topic == null || !context.mounted) return;

    if (topic.anchorId == null) {
      await showHelpTopicDialog(
        context,
        title: topic.title,
        description: topic.description,
      );
      return;
    }

    final registry = ref.read(helpAnchorRegistryProvider(pageId));

    await showHelpSpotlight(
      context,
      anchorKey: registry.keyFor(topic.anchorId!),
      title: topic.title,
      description: topic.description,
    );
  }
}
