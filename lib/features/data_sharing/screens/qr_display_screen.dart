import 'package:flutter/material.dart';

import '../domain/models/share/share_archive.dart';

class QrDisplayScreen extends StatelessWidget {
  const QrDisplayScreen({
    super.key,
    required this.archive,
  });

  final ShareArchive archive;

  @override
  Widget build(BuildContext context) {
    final manifest = archive.manifest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Ready',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Archive Version: ${manifest.archiveVersion}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Resources: ${manifest.resourceCount}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Created: ${manifest.createdAt}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Expanded(
              child: Center(
                child: Text(
                  'QR generation coming next.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}