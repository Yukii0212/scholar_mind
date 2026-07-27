import 'package:flutter/material.dart';

import '../domain/models/share/share_archive.dart';
import '../widgets/screen/share/share_link_view.dart';
import '../widgets/screen/share/share_qr_view.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({
    super.key,
    required this.archive,
  });

  final ShareArchive archive;

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share your study materials',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Anyone with ScholarMind can import these materials.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.standard,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      icon: Icon(Icons.qr_code_rounded),
                      label: Text('QR Code'),
                    ),
                    ButtonSegment(
                      value: 1,
                      icon: Icon(Icons.link_rounded),
                      label: Text('Link'),
                    ),
                  ],
                  selected: {_selectedIndex},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _selectedIndex = selection.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _selectedIndex == 0
                      ? ShareQrView(
                    archive: widget.archive,
                  )
                      : ShareLinkView(
                    archive: widget.archive,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}