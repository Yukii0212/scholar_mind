import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders an Office document (e.g. .pptx) via Google Docs Viewer, since
/// there's no native Flutter renderer for OOXML slides.
///
/// This sends [fileUrl] to a third-party Google service and requires an
/// internet connection — [onOpenExternally] is offered as a fallback for
/// offline use or when the viewer itself fails to load. The viewer page
/// often loads "successfully" (HTTP-wise) while showing its own error
/// message for a file it can't preview, so [_pageShowsError] inspects the
/// loaded page's text for that case too, not just network-level failures.
class OfficeDocumentViewerScreen extends StatefulWidget {
  const OfficeDocumentViewerScreen({
    super.key,
    required this.fileUrl,
    required this.title,
    required this.onOpenExternally,
  });

  final String fileUrl;
  final String title;
  final Future<void> Function() onOpenExternally;

  @override
  State<OfficeDocumentViewerScreen> createState() =>
      _OfficeDocumentViewerScreenState();
}

class _OfficeDocumentViewerScreenState
    extends State<OfficeDocumentViewerScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            final hasError = await _pageShowsError();

            if (!mounted) return;

            setState(() {
              _isLoading = false;
              _hasError = hasError;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(_viewerUri());
  }

  Uri _viewerUri() {
    return Uri.parse(
      'https://docs.google.com/viewer'
      '?url=${Uri.encodeComponent(widget.fileUrl)}&embedded=true',
    );
  }

  // The viewer page frequently loads fine at the HTTP level while showing
  // its own "can't preview this" message, so a plain onWebResourceError
  // check misses it — this inspects the rendered page's own text instead.
  Future<bool> _pageShowsError() async {
    try {
      final result = await _controller.runJavaScriptReturningResult(
        'document.body ? document.body.innerText.toLowerCase() : ""',
      );

      final text = result.toString();

      const errorPhrases = [
        'file not found',
        'not publicly accessible',
        "couldn't preview",
        'cannot preview',
        'no preview available',
        "can't display",
        "can't open this file",
        'unable to display',
        'unable to load',
      ];

      return errorPhrases.any(text.contains);
    } catch (_) {
      return false;
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    _controller.loadRequest(_viewerUri());
  }

  @override
  Widget build(BuildContext context) {
    // Same reasoning as PdfViewerScreen: the platform-view-backed WebView
    // doesn't tolerate the transient layout pass an interactive
    // edge-swipe/predictive-back gesture puts this route through.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        // The Android WebView doesn't handle being resized by Flutter's
        // own keyboard-avoidance while one of its own text inputs (e.g.
        // the viewer's page-number field) has focus — the resize reads
        // as a blur, so the keyboard flickers shut and the page's own
        // input handler can fire on whatever default/partial value was
        // left behind. Leaving the WebView's size alone and letting the
        // native view handle the keyboard itself avoids that.
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: _hasError
            ? _ErrorState(
                onRetry: _retry,
                onOpenExternally: widget.onOpenExternally,
              )
            : Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.onRetry,
    required this.onOpenExternally,
  });

  final VoidCallback onRetry;
  final Future<void> Function() onOpenExternally;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 16),
            const Text(
              "Couldn't load this document in-app. "
              'Check your connection, or open it in another app.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
                FilledButton(
                  onPressed: onOpenExternally,
                  child: const Text('Open externally'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
