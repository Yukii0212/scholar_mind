import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_design.dart';
import '../domain/help_step.dart';

/// Runs a step-by-step tutorial for [steps], spotlighting each step's
/// anchor in turn (resolved via [resolveAnchor]) with a Back/Next bubble.
/// A step with no anchor id, or whose anchor isn't currently mounted (e.g.
/// a different page of a swipe carousel), shows a centered bubble with no
/// cutout instead of failing.
///
/// Returns once the tutorial is dismissed (Done, the X button, or tapping
/// outside), so callers can resume whatever they were doing before it —
/// e.g. reopening a topic list to let the user pick another one.
Future<void> showHelpTutorial(
  BuildContext context, {
  required List<HelpStep> steps,
  required GlobalKey? Function(String anchorId) resolveAnchor,
  VoidCallback? onDismiss,
}) {
  if (steps.isEmpty) return Future.value();

  final completer = Completer<void>();
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _HelpTutorial(
      steps: steps,
      resolveAnchor: resolveAnchor,
      onDismiss: () {
        entry.remove();
        onDismiss?.call();
        if (!completer.isCompleted) completer.complete();
      },
    ),
  );

  // `Overlay.of(context, rootOverlay: true)` can resolve to a nested
  // ShellRoute Navigator's own (body-scoped) overlay rather than the true
  // app-root one, which both leaves the AppBar/bottom nav outside its paint
  // area and shifts its local coordinate origin away from (0, 0) — throwing
  // off every anchor rect, which is computed in true global coordinates.
  // Going through the root Navigator explicitly avoids both problems.
  Navigator.of(context, rootNavigator: true).overlay!.insert(entry);

  return completer.future;
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
    // _prepareStep can run a step's beforeShow callback, which may call
    // setState on a widget elsewhere in the tree (e.g. switching a tab on
    // the screen behind this overlay). Doing that synchronously here would
    // happen while the framework is still in the middle of building this
    // very overlay entry, which throws — defer to after this frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _prepareStep();
    });
  }

  Future<void> _prepareStep() async {
    setState(() => _measuring = true);

    final step = widget.steps[_index];

    if (step.beforeShow != null) {
      // beforeShow owns its own waiting (frames, animations) and is
      // awaited to completion before we try to measure anything below, so
      // by the time this returns the anchor should be in its final,
      // settled position.
      await step.beforeShow!();
      if (!mounted) return;
    }

    final anchorId = step.anchorId;

    Rect? measure() {
      final key = anchorId == null ? null : widget.resolveAnchor(anchorId);
      final box = key?.currentContext?.findRenderObject() as RenderBox?;
      final attached = box != null && box.attached;
      return attached ? (box.localToGlobal(Offset.zero) & box.size).inflate(8) : null;
    }

    Future<void> scrollIntoView() async {
      final key = anchorId == null ? null : widget.resolveAnchor(anchorId);
      final anchorContext = key?.currentContext;

      if (anchorContext != null && mounted) {
        await Scrollable.ensureVisible(
          anchorContext,
          duration: const Duration(milliseconds: 250),
          alignment: 0.5,
        );
      }
    }

    await scrollIntoView();
    if (!mounted) return;

    var rect = measure();

    // A step's beforeShow can switch to content that mounts for the first
    // time right as we're about to measure (e.g. a page whose own data
    // provider is still resolving its first snapshot) — its anchor can
    // still shift position for a frame or two after our first look. Give
    // it one more frame, then re-scroll and re-measure so the ring lands
    // on where the anchor actually settles rather than a transient spot.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    await scrollIntoView();
    if (!mounted) return;

    final resettled = measure();
    if (resettled != null) rect = resettled;

    setState(() {
      _rect = rect;
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
    final highlightColor = context.scholarPalette.brandEnd;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: CustomPaint(
              size: screenSize,
              painter: _SpotlightPainter(
                rect: _measuring ? null : _rect,
                highlightColor: highlightColor,
                scrimOpacity: widget.steps[_index].scrimOpacity,
                showHighlightRing: widget.steps[_index].showHighlightRing,
              ),
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
              colorLegend: widget.steps[_index].colorLegend,
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
    // Only the horizontal position used to be clamped to the screen — the
    // vertical side picked above/below purely from which half of the
    // screen the anchor sat in, with no regard for the bubble's actual
    // height or for system insets (status bar, notch, gesture/nav bar).
    // An anchor near an edge, or a bubble tall enough not to fit in
    // whichever half got picked, could render partly or fully off-screen
    // — this happens on any device, not just small ones; a small screen
    // just leaves less room to get away with it unnoticed. Constrain to
    // the actual safe viewport on every side, size the bubble to what's
    // available in the direction it's placed, and let its content scroll
    // internally as the last resort instead of overflowing the screen.
    final safeArea = MediaQuery.paddingOf(context);
    const margin = 16.0;

    const safeLeft = margin;
    final safeTop = safeArea.top + margin;
    final safeRight = screenSize.width - safeArea.right - margin;
    final safeBottom = screenSize.height - safeArea.bottom - margin;

    final bubbleWidth = math.min(340.0, safeRight - safeLeft);

    if (rect == null) {
      return Positioned(
        left: safeLeft,
        top: safeTop,
        right: screenSize.width - safeRight,
        bottom: screenSize.height - safeBottom,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: bubbleWidth,
              maxHeight: safeBottom - safeTop,
            ),
            child: SingleChildScrollView(child: child),
          ),
        ),
      );
    }

    final spaceBelow = safeBottom - rect!.bottom - margin;
    final spaceAbove = rect!.top - safeTop - margin;
    final showBelow = spaceBelow >= spaceAbove;
    final maxBubbleHeight =
        math.max(120.0, showBelow ? spaceBelow : spaceAbove);

    final left = rect!.left.clamp(safeLeft, safeRight - bubbleWidth);

    return Positioned(
      left: left,
      width: bubbleWidth,
      top: showBelow ? rect!.bottom + margin : null,
      bottom: showBelow ? null : screenSize.height - rect!.top + margin,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxBubbleHeight),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.rect,
    required this.highlightColor,
    required this.scrimOpacity,
    required this.showHighlightRing,
  });

  final Rect? rect;
  final Color highlightColor;
  final double scrimOpacity;
  final bool showHighlightRing;

  @override
  void paint(Canvas canvas, Size size) {
    final scrimPaint = Paint()
      ..color = Colors.black.withValues(alpha: scrimOpacity);

    if (rect == null) {
      canvas.drawRect(Offset.zero & size, scrimPaint);
      return;
    }

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final rrect = RRect.fromRectAndRadius(rect!, const Radius.circular(12));

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, scrimPaint);
    canvas.drawRRect(rrect, clearPaint);
    canvas.restore();

    if (showHighlightRing) {
      final ringPaint = Paint()
        ..color = highlightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawRRect(rrect, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.rect != rect ||
      oldDelegate.highlightColor != highlightColor ||
      oldDelegate.scrimOpacity != scrimOpacity ||
      oldDelegate.showHighlightRing != showHighlightRing;
}

class _TutorialBubble extends StatelessWidget {
  const _TutorialBubble({
    required this.stepNumber,
    required this.stepCount,
    required this.description,
    required this.colorLegend,
    required this.onClose,
    required this.onBack,
    required this.onNext,
    required this.onDone,
  });

  final int stepNumber;
  final int stepCount;
  final String description;
  final List<HelpColorLegendEntry>? colorLegend;
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
            if (colorLegend != null && colorLegend!.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final entry in colorLegend!)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: entry.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
