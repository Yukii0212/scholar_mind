import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/models/share/share_link_record.dart';
import '../domain/models/share/share_result.dart';
import '../providers/share/my_share_links_provider.dart';
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

class _ShareLinkTile extends StatelessWidget {
  const _ShareLinkTile({required this.link});

  final ShareLinkRecord link;

  @override
  Widget build(BuildContext context) {
    final expired = link.isExpired;
    final createdLabel = link.createdAt == null
        ? 'Unknown date'
        : DateFormat("MMM d, yyyy 'at' h:mm a")
        .format(link.createdAt!.toLocal());

    final statusParts = <String>[
      expired ? 'Expired' : 'Active',
      if (link.expiresAt != null)
        'expires ${DateFormat('MMM d, yyyy').format(link.expiresAt!.toLocal())}',
      '${link.downloadCount} import${link.downloadCount == 1 ? '' : 's'}',
    ];

    return Card(
      child: ListTile(
        leading: Icon(
          expired ? Icons.link_off_rounded : Icons.link_rounded,
          color: expired
              ? Theme.of(context).colorScheme.outline
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text('Created $createdLabel'),
        subtitle: Text(statusParts.join(' • ')),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _openLink(context),
      ),
    );
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
