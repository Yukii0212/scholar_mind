import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShareHubScreen extends StatelessWidget {
  const ShareHubScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Share',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ShareOptionCard(
              icon: Icons.upload_rounded,
              title: 'Export Materials',
              subtitle:
              'Share your study materials with other ScholarMind users.',
              onTap: () {
                context.push('/export');
              },
            ),
            const SizedBox(
              height: 16,
            ),
            _ShareOptionCard(
              icon: Icons.download_rounded,
              title: 'Import Materials',
              subtitle:
              'Import study materials shared with you.',
              onTap: () {
                context.push('/import');
              },
            ),
            const SizedBox(
              height: 16,
            ),
            _ShareOptionCard(
              icon: Icons.history_rounded,
              title: 'Shared Links',
              subtitle:
              'View, reuse, or revoke links you\'ve generated.',
              onTap: () {
                context.push('/share/links');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOptionCard extends StatelessWidget {
  const _ShareOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              const Icon(
                Icons.chevron_right_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}