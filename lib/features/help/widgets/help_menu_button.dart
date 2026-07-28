import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_design.dart';
import '../domain/help_topic.dart';
import '../providers/help_anchor_registry_provider.dart';
import 'help_tutorial_overlay.dart';

/// Help icon for a single page. Tapping it opens a sheet listing [topics]
/// for that page (identified by [pageId]); picking one runs a step-by-step
/// tutorial spotlighting the relevant part of the screen. Nothing happens
/// until the user opts in.
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _HelpTopicSheet(
          topics: topics,
          scrollController: scrollController,
        ),
      ),
    );

    if (topic == null || !context.mounted) return;

    final registry = ref.read(helpAnchorRegistryProvider(pageId));

    showHelpTutorial(
      context,
      steps: topic.steps,
      resolveAnchor: registry.keyFor,
    );
  }
}

class _HelpTopicSheet extends StatelessWidget {
  const _HelpTopicSheet({
    required this.topics,
    required this.scrollController,
  });

  final List<HelpTopic> topics;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      decoration: BoxDecoration(
        color: palette.canvasDeep,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: palette.stroke,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Help topics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: topics.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final topic = topics[index];

                return Material(
                  color: palette.panelStrong.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context, topic),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: palette.stroke.withValues(alpha: 0.72),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              topic.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: palette.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
