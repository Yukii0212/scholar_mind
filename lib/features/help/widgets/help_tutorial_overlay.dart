import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_design.dart';
import '../domain/help_step.dart';

/// Runs a step-by-step tutorial for [steps], spotlighting each step's
/// anchor in turn (resolved via [resolveAnchor]) with a Back/Next bubble.
/// A step with no anchor id, or whose anchor isn't currently mounted (e.g.
/// a different page of a swipe carousel), shows a centered bubble with no
/// cutout instead of failing.
void showHelpTutorial(
  BuildContext context, {
  required List<HelpStep> steps,
  required GlobalKey? Function(String anchorId) resolveAnchor,
}) {
  if (steps.isEmpty) return;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _HelpTutorial(
      steps: steps,
      resolveAnchor: resolveAnchor,
      onDismiss: () => entry.remove(),
    ),
  );

  Overlay.of(context, rootOverlay: true).insert(entry);
}

class _HelpTutorial extends StatefulWidget {
  const _HelpTutorial({
    required this.steps,
    required this.resolveAnchor,
    required this.onDismiss,
  });

  final List<HelpStep> steps;
  final GlobalKey? Function(String anchorId) resolveAnchor;
  final VoidCallback onDismiss;

  @override
  State<_HelpTutorial> createState() => _HelpTutorialState();
}

class _HelpTutorialState extends State<_HelpTutorial> {
  int _index = 0;
  Rect? _rect;
  bool _measuring = true;

  @override
  void initState() {
    super.initState();
    _prepareStep();
  }

  Future<void> _prepareStep() async {
    setState(() => _measuring = true);

    final anchorId = widget.steps[_index].anchorId;
    final key = anchorId == null ? null : widget.resolveAnchor(anchorId);
    final anchorContext = key?.currentContext;

    if (anchorContext != null) {
      await Scrollable.ensureVisible(
        anchorContext,
        duration: const Duration(milliseconds: 250),
        alignment: 0.5,
      );
    }

    if (!mounted) return;

    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    final attached = box != null && box.attached;

    setState(() {
      _rect = attached ? (box.localToGlobal(Offset.zero) & box.size).inflate(8) : null;
      _measuring = false;
    });
  }

  void _goTo(int index) {
    setState(() => _index = index);
    _prepareStep();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isFirst = _index == 0;
    final isLast = _index == widget.steps.length - 1;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: CustomPaint(
              size: screenSize,
              painter: _SpotlightPainter(rect: _measuring ? null : _rect),
            ),
          ),
        ),
        if (!_measuring)
          _TutorialBubbleLayout(
            rect: _rect,
            screenSize: screenSize,
            child: _TutorialBubble(
              stepNumber: _index + 1,
              stepCount: widget.steps.length,
              description: widget.steps[_index].description,
              onClose: widget.onDismiss,
              onBack: isFirst ? null : () => _goTo(_index - 1),
              onNext: isLast ? null : () => _goTo(_index + 1),
              onDone: isLast ? widget.onDismiss : null,
            ),
          ),
      ],
    );
  }
}

class _TutorialBubbleLayout extends StatelessWidget {
  const _TutorialBubbleLayout({
    required this.rect,
    required this.screenSize,
    required this.child,
  });

  final Rect? rect;
  final Size screenSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bubbleWidth = math.min(340.0, screenSize.width - 32);

    if (rect == null) {
      return Center(
        child: SizedBox(width: bubbleWidth, child: child),
      );
    }

    final showBelow = rect!.center.dy < screenSize.height / 2;
    final left = rect!.left.clamp(16.0, screenSize.width - bubbleWidth - 16);

    return Positioned(
      left: left,
      width: bubbleWidth,
      top: showBelow ? rect!.bottom + 16 : null,
      bottom: showBelow ? null : screenSize.height - rect!.top + 16,
      child: child,
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({required this.rect});

  final Rect? rect;

  @override
  void paint(Canvas canvas, Size size) {
    final scrimPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);

    if (rect == null) {
      canvas.drawRect(Offset.zero & size, scrimPaint);
      return;
    }

    final clearPaint = Paint()..blendMode = BlendMode.clear;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, scrimPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect!, const Radius.circular(12)),
      clearPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.rect != rect;
}

class _TutorialBubble extends StatelessWidget {
  const _TutorialBubble({
    required this.stepNumber,
    required this.stepCount,
    required this.description,
    required this.onClose,
    required this.onBack,
    required this.onNext,
    required this.onDone,
  });

  final int stepNumber;
  final int stepCount;
  final String description;
  final VoidCallback onClose;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onDone;

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
            Row(
              children: [
                if (stepCount > 1)
                  Text(
                    'Step $stepNumber of $stepCount',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: palette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                const Spacer(),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(999),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (onBack != null)
                  TextButton(
                    onPressed: onBack,
                    child: const Text('Back'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: onNext ?? onDone,
                  child: Text(onNext != null ? 'Next' : 'Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
