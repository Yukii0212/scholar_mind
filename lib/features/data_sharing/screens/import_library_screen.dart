import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/share_import_controller.dart';
import 'import_preview_screen.dart';
import 'qr_scanner_screen.dart';

class ImportLibraryScreen extends ConsumerStatefulWidget {
  const ImportLibraryScreen({
    super.key,
    this.initialShareInput,
  });

  /// Pre-fills the input field and immediately triggers the import, for
  /// entry points that already have a link/code in hand (e.g. a "Scan QR"
  /// quick action) rather than expecting the user to paste one here.
  final String? initialShareInput;

  @override
  ConsumerState<ImportLibraryScreen> createState() =>
      _ImportLibraryScreenState();
}

class _ImportLibraryScreenState
    extends ConsumerState<ImportLibraryScreen> {
  final _controller = TextEditingController();

  bool _isImporting = false;

  @override
  void initState() {
    super.initState();

    final initialInput = widget.initialShareInput;

    if (initialInput != null && initialInput.isNotEmpty) {
      _controller.text = initialInput;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _import();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final input = _controller.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a share link or share ID.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isImporting = true;
    });

    try {
      final shareId = _extractShareId(input);

      final archive = await ref
          .read(
        shareImportControllerProvider.notifier,
      )
          .importFromShareId(
        shareId,
      );

      if (!mounted) {
        return;
      }

      final imported = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ImportPreviewScreen(
            archive: archive,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (imported == true) {
        _controller.clear();

        Navigator.of(context).pop();
      }
    } catch (e, st) {
      if (!mounted) {
        return;
      }

      debugPrint('========== SHARE IMPORT FAILED ==========');
      debugPrint('Error: $e');
      debugPrint('Stack Trace:');
      debugPrint(st.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  String _extractShareId(
      String input,
      ) {
    final uri = Uri.tryParse(input);

    if (uri != null &&
        uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }

    return input;
  }

  Future<void> _scanQrCode() async {
    final scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(),
      ),
    );

    if (scanned == null || !mounted) {
      return;
    }

    _controller.text = scanned;

    await _import();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Import Materials',
        ),
        actions: [
          IconButton(
            onPressed: _isImporting ? null : _scanQrCode,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Scan QR code',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
              TextField(
                controller: _controller,
                enabled: !_isImporting,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Share Link or Share ID',
                  hintText:
                  'Paste a ScholarMind share link or share ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              FilledButton.icon(
                onPressed:
                _isImporting ? null : _import,
                icon: _isImporting
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.download_rounded,
                ),
                label: Text(
                  _isImporting
                      ? 'Importing...'
                      : 'Import',
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Card(
                child: Padding(
                  padding:
                  const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supported Input',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const SelectableText(
                        '• Share ID\n'
                            '• ScholarMind share link\n'
                            '• Scan a share QR code (top right)',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}