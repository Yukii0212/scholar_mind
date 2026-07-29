import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/share/share_expiry.dart';
import '../domain/models/share/share_result.dart';
import '../providers/export/export_controller.dart';
import '../widgets/screen/share/share_link_view.dart';
import '../widgets/screen/share/share_qr_view.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({
    super.key,
  });

  @override
  ConsumerState<ShareScreen> createState() =>
      _ShareScreenState();
}

class _ShareScreenState
    extends ConsumerState<ShareScreen> {
  var _selectedIndex = 1;

  ShareResult? _share;

  bool _generating = false;

  ShareExpiry _expiry = ShareExpiry.oneDay;

  @override
  Widget build(BuildContext context) {
    final hasShare = _share != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share'),
        actions: [
          if (hasShare)
            TextButton.icon(
              onPressed: _generating
                  ? null
                  : () async {
                setState(() {
                  _generating = true;
                });

                try {
                  final share = await ref
                      .read(
                    exportControllerProvider.notifier,
                  )
                      .generateShare(
                    expiry: _expiry,
                  );

                  if (!mounted) {
                    return;
                  }

                  setState(() {
                    _share = share;
                  });
                } finally {
                  if (mounted) {
                    setState(() {
                      _generating = false;
                    });
                  }
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('New Link'),
            ),
        ],
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

              if (!hasShare) ...[
                const SizedBox(height: 24),

                DropdownButtonFormField<ShareExpiry>(
                  value: _expiry,
                  decoration: const InputDecoration(
                    labelText: 'Link Expiry',
                    border: OutlineInputBorder(),
                  ),
                  items: ShareExpiry.values
                      .map(
                        (expiry) => DropdownMenuItem(
                      value: expiry,
                      child: Text(expiry.label),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _expiry = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                FilledButton.icon(
                  onPressed: _generating
                      ? null
                      : () async {
                    setState(() {
                      _generating = true;
                    });

                    try {
                      final share = await ref
                          .read(
                        exportControllerProvider.notifier,
                      )
                          .generateShare(
                        expiry: _expiry,
                      );

                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        _share = share;
                        _selectedIndex = 1;
                      });
                    } finally {
                      if (mounted) {
                        setState(() {
                          _generating = false;
                        });
                      }
                    }
                  },
                  icon: _generating
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.link),
                  label: const Text(
                    'Generate Link',
                  ),
                ),
              ],

              const SizedBox(height: 24),

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
                      ? ShareQrView(
                    share: _share,
                  )
                      : ShareLinkView(
                    share: _share,
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