import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/models/share/share_link_record.dart';
import '../domain/models/share/share_result.dart';
import '../providers/share/my_share_links_provider.dart';
import '../providers/share/share_link_service_provider.dart';
import 'view_shared_link_screen.dart';

class MySharedLinksScreen extends ConsumerWidget {
  const MySharedLinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(myShareLinksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shared Links'),
      ),
      body: linksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Unable to load shared links: $error'),
        ),
        data: (allLinks) {
          // Expired links have nothing left to do — they can't be
          // imported from anymore, so surfacing them just adds noise
          // to a list meant for finding and reusing an active link.
          final links =
              allLinks.where((link) => !link.isExpired).toList();

          if (links.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No active shared links',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Links you generate from the Share screen will '
                      'show up here so you can find them again later.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: links.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _ShareLinkTile(
              link: links[index],
            ),
          );
        },
      ),
    );
  }
}

class _ShareLinkTile extends ConsumerWidget {
  const _ShareLinkTile({required this.link});

  final ShareLinkRecord link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createdLabel = link.createdAt == null
        ? 'Unknown date'
        : DateFormat('MMM d, yyyy').format(link.createdAt!.toLocal());

    final metaParts = <String>[
      link.isRevoked ? 'Revoked' : 'Active',
      'Generated $createdLabel',
      '${link.downloadCount} import${link.downloadCount == 1 ? '' : 's'}',
    ];

    return Card(
      child: ListTile(
        leading: Icon(
          link.isRevoked ? Icons.link_off_rounded : Icons.link_rounded,
          color: link.isRevoked
              ? Theme.of(context).colorScheme.outline
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          link.contentsSummary,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Text(metaParts.join(' • ')),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'view') {
              _openLink(context);
            } else if (value == 'revoke') {
              _confirmRevoke(context, ref);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('View'),
            ),
            if (!link.isRevoked)
              const PopupMenuItem(
                value: 'revoke',
                child: Text('Revoke'),
              ),
          ],
        ),
        onTap: () => _openLink(context),
      ),
    );
  }

  Future<void> _confirmRevoke(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke this link?'),
        content: const Text(
          'Anyone who still has this link or QR code will no longer '
          'be able to import from it. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(shareLinkServiceProvider).revokeLink(link.shareId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link revoked.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not revoke link: $e')),
        );
      }
    }
  }

  void _openLink(BuildContext context) {
    final share = ShareResult(
      shareId: link.shareId,
      shareUrl: link.shareUrl,
      storagePath: link.storagePath,
      expiresAt: link.expiresAt,
      resourceCounts: link.resourceCounts,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ViewSharedLinkScreen(share: share),
      ),
    );
  }
}
