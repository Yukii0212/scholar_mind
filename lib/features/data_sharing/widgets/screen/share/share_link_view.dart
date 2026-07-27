import 'package:flutter/material.dart';

import '../../../domain/models/share/share_archive.dart';

class ShareLinkView extends StatelessWidget {
  const ShareLinkView({
    super.key,
    required this.archive,
  });

  final ShareArchive archive;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Share link generation coming in the next sprint.',
      ),
    );
  }
}