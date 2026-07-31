import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/models/share/share_link_record.dart';
import '../domain/models/share/share_result.dart';
import '../providers/share/my_share_links_provider.dart';
import '../providers/share/share_link_service_provider.dart';
import '../widgets/screen/share/share_link_view.dart';
import '../widgets/screen/share/share_qr_view.dart';

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
        data: (links) {
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
                      'No shared links yet',
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
    final inactive = link.isRevoked || link.isExpired;

    final status = link.isRevoked
        ? 'Revoked'
        : link.isExpired
            ? 'Expired'
            : 'Active';

    final createdLabel = link.createdAt == null
        ? 'Unknown date'
        : DateFormat("MMM d, yyyy 'at' h:mm a")
        .format(link.createdAt!.toLocal());

    final statusParts = <String>[
      status,
      if (!link.isRevoked && link.expiresAt != null)
        'expires ${DateFormat('MMM d, yyyy').format(link.expiresAt!.toLocal())}',
      '${link.downloadCount} import${link.downloadCount == 1 ? '' : 's'}',
    ];

    return Card(
      child: ListTile(
        leading: Icon(
          inactive ? Icons.link_off_rounded : Icons.link_rounded,
          color: inactive
              ? Theme.of(context).colorScheme.outline
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text('Created $createdLabel'),
        subtitle: Text(statusParts.join(' • ')),
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
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return DefaultTabController(
              length: 2,
              child: SafeArea(
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.qr_code), text: 'QR Code'),
                        Tab(icon: Icon(Icons.link), text: 'Link'),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TabBarView(
                          children: [
                            ShareQrView(share: share),
                            ShareLinkView(share: share),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
