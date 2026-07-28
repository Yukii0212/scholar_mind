import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_design.dart';
import 'help_topic_dialog.dart';

/// Shows a short, on-demand explanation for the widget behind [anchorKey]:
/// dims the rest of the screen, cuts a hole around that widget, and shows
/// a callout with [title]/[description]. Dismissed by tapping anywhere or
/// the "Got it" button.
///
/// Falls back to a plain [showHelpTopicDialog] when the anchor isn't
/// currently mounted (e.g. it's conditionally hidden, or on a different
/// page of a swipe carousel).
Future<void> showHelpSpotlight(
  BuildContext context, {
  required GlobalKey anchorKey,
  required String title,
  required String description,
}) async {
  final anchorContext = anchorKey.currentContext;

  if (anchorContext == null) {
    await showHelpTopicDialog(
      context,
      title: title,
      description: description,
    );
    return;
  }

  await Scrollable.ensureVisible(
    anchorContext,
    duration: const Duration(milliseconds: 300),
    alignment: 0.5,
  );

  if (!context.mounted) return;

  final box = anchorKey.currentContext?.findRenderObject() as RenderBox?;

  if (box == null || !box.attached) {
    await showHelpTopicDialog(
      context,
      title: title,
      description: description,
    );
    return;
  }

  final rect = (box.localToGlobal(Offset.zero) & box.size).inflate(8);
  final screenSize = MediaQuery.sizeOf(context);

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _HelpSpotlight(
      rect: rect,
      screenSize: screenSize,
      title: title,
      description: description,
      onDismiss: () => entry.remove(),
    ),
  );

  Overlay.of(context, rootOverlay: true).insert(entry);
}

class _HelpSpotlight extends StatelessWidget {
  const _HelpSpotlight({
    required this.rect,
    required this.screenSize,
    required this.title,
    required this.description,
    required this.onDismiss,
  });

  final Rect rect;
  final Size screenSize;
  final String title;
  final String description;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final bubbleWidth = math.min(340.0, screenSize.width - 32);
    final showBelow = rect.center.dy < screenSize.height / 2;
    final left = rect.left.clamp(16.0, screenSize.width - bubbleWidth - 16);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
            child: CustomPaint(
              size: screenSize,
              painter: _SpotlightPainter(rect: rect),
            ),
          ),
        ),
        Positioned(
          left: left,
          width: bubbleWidth,
          top: showBelow ? rect.bottom + 16 : null,
          bottom: showBelow ? null : screenSize.height - rect.top + 16,
          child: _SpotlightBubble(
            title: title,
            description: description,
            onDismiss: onDismiss,
          ),
        ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({required this.rect});

  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    final scrimPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final clearPaint = Paint()..blendMode = BlendMode.clear;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, scrimPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      clearPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.rect != rect;
}

class _SpotlightBubble extends StatelessWidget {
  const _SpotlightBubble({
    required this.title,
    required this.description,
    required this.onDismiss,
  });

  final String title;
  final String description;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: palette.panelGradient,
          border: Border.all(color: palette.stroke.withValues(alpha: 0.78)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.32),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onDismiss,
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
