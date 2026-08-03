import 'package:flutter/material.dart';

import '../domain/models/share/share_result.dart';
import '../widgets/screen/share/share_contents_banner.dart';
import '../widgets/screen/share/share_link_view.dart';
import '../widgets/screen/share/share_qr_view.dart';

/// Full-page view of a single, already-generated share link — used instead
/// of a bottom sheet so the QR/link content (and its Save/Share buttons)
/// gets the whole screen's height rather than a cramped sheet where those
/// buttons could sit below the fold with no visible cue to scroll.
class ViewSharedLinkScreen extends StatefulWidget {
  const ViewSharedLinkScreen({
    super.key,
    required this.share,
  });

  final ShareResult share;

  @override
  State<ViewSharedLinkScreen> createState() => _ViewSharedLinkScreenState();
}

class _ViewSharedLinkScreenState extends State<ViewSharedLinkScreen> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Link'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShareContentsBanner(share: widget.share),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      icon: Icon(Icons.qr_code),
                      label: Text('QR Code'),
                    ),
                    ButtonSegment(
                      value: 1,
                      icon: Icon(Icons.link),
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
                      ? ShareQrView(share: widget.share)
                      : ShareLinkView(share: widget.share),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
