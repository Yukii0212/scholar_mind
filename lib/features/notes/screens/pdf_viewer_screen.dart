import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({
    super.key,
    required this.file,
    required this.title,
  });

  final File file;
  final String title;

  @override
  Widget build(BuildContext context) {
    // SfPdfViewer's internal viewport doesn't tolerate being laid out
    // mid-transition during an interactive edge-swipe-back gesture (its
    // page briefly gets a fractional-translation layout pass before its
    // size stabilises) — disabling the interactive/predictive pop for
    // just this screen avoids that, while a normal back tap/gesture
    // still pops immediately as usual.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SfPdfViewer.file(file),
      ),
    );
  }
}
