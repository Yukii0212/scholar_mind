import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controller/share_import_controller.dart';
import 'import_preview_screen.dart';

/// Landing screen for a `scholarmind://share/{id}` deep link — resolves the
/// share id automatically and hands off to the normal import preview flow,
/// skipping the manual paste-a-link step.
class ImportShareLinkScreen extends ConsumerStatefulWidget {
  const ImportShareLinkScreen({
    super.key,
    required this.shareId,
  });

  final String shareId;

  @override
  ConsumerState<ImportShareLinkScreen> createState() =>
      _ImportShareLinkScreenState();
}

class _ImportShareLinkScreenState
    extends ConsumerState<ImportShareLinkScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _resolve(),
    );
  }

  Future<void> _resolve() async {
    try {
      final archive = await ref
          .read(
        shareImportControllerProvider.notifier,
      )
          .importFromShareId(
        widget.shareId,
      );

      if (!mounted) return;

      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ImportPreviewScreen(
            archive: archive,
            shareId: widget.shareId,
          ),
        ),
      );

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Import'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _error = null);
                        _resolve();
                      },
                      child: const Text('Try Again'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Go to Home'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
