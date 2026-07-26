import 'package:flutter/material.dart';

import '../../domain/models/share/share_method.dart';



class ExportMethodBottomSheet extends StatelessWidget {
  const ExportMethodBottomSheet({
    super.key,
    required this.onSelected,
  });

  final ValueChanged<ShareMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          24,
          24,
          24,
          32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Export Method',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Select how you would like to share your exported study materials.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => onSelected(
                ShareMethod.qrCode,
              ),
              icon: const Icon(Icons.qr_code_rounded),
              label: const Text('QR Code'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => onSelected(
                ShareMethod.shareLink,
              ),
              icon: const Icon(Icons.link_rounded),
              label: const Text('Share Link'),
            ),
          ],
        ),
      ),
    );
  }
}