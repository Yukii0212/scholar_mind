import 'package:flutter/material.dart';

import '../../../domain/models/share/share_archive.dart';

class ShareQrView extends StatelessWidget {
  const ShareQrView({
    super.key,
    required this.archive,
  });

  final ShareArchive archive;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'QR generation coming in the next sprint.',
      ),
    );
  }
}