import 'package:flutter/material.dart';

import 'study_swipe_card_item.dart';

class StudySwipeCards extends StatefulWidget {
  const StudySwipeCards({
    super.key,
    required this.item,
    required this.hintText,
    this.enabled = true,
    this.leftLabel,
    this.leftColor,
    this.rightLabel,
    this.rightColor,
  });

  final StudySwipeCardItem item;

  /// Shown above the card, e.g. "Swipe either way to skip" on the
  /// question or "Swipe right: I knew it • Swipe left: Didn't know it"
  /// on the answer — meaning changes with which side is showing, so the
  /// caller supplies it rather than this widget hardcoding one label.
  final String hintText;

  final bool enabled;

  /// When both a label and a color are given for a direction, dragging
  /// that way reveals a Tinder-style stamp (label in that color, fading
  /// in with drag distance) confirming what letting go there will do —
  /// text alone ("swipe left/right") isn't a clear enough affordance on
  /// its own for what each direction actually means. Leave both null for
  /// a direction that has no distinct outcome to preview (e.g. skip,
  /// which means the same thing either way).
  final String? leftLabel;
  final Color? leftColor;
  final String? rightLabel;
  final Color? rightColor;

  @override
  State<StudySwipeCards> createState() =>
      _StudySwipeCardsState();
}

class _StudySwipeCardsState
    extends State<StudySwipeCards>
    with SingleTickerProviderStateMixin {

  static const double _dismissThreshold = 120;

  late final AnimationController _controller;

  late Animation<Offset> _animation;

  Offset _offset = Offset.zero;

  double get _rotation =>
      (_offset.dx / 450) * 0.18;

  bool _animatingAway = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 220,
      ),
    );

    _animation =
        AlwaysStoppedAnimation(_offset);

    _controller.addListener(() {
      setState(() {
        _offset = _animation.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status ==
          AnimationStatus.completed &&
          _animatingAway) {

        // `_animateDismiss` only ever flips the magnitude of `_offset.dx`
        // toward +/-700, preserving its sign — so it's still a reliable
        // read of which way the card was actually swiped once the fling
        // animation finishes.
        if (_offset.dx >= 0) {
          widget.item.onSwipeRight();
        } else {
          widget.item.onSwipeLeft();
        }

        _offset = Offset.zero;

        _animatingAway = false;

        _controller.reset();
      }
    });
  }

  @override
  void didUpdateWidget(
      covariant StudySwipeCards oldWidget) {
    super.didUpdateWidget(oldWidget);

    _controller.reset();

    _offset = Offset.zero;

    _animatingAway = false;
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _animateBack() {

    _animation = Tween(
      begin: _offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _animatingAway = false;

    _controller
      ..reset()
      ..forward();
  }

  void _animateDismiss() {

    final direction =
    _offset.dx >= 0 ? 1.0 : -1.0;

    _animation = Tween(
      begin: _offset,
      end: Offset(
        direction * 700,
        _offset.dy,
      ),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _animatingAway = true;

    _controller
      ..reset()
      ..forward();
  }

  Widget _buildStamp() {
    final isRight = _offset.dx > 0;

    final label = isRight ? widget.rightLabel : widget.leftLabel;
    final color = isRight ? widget.rightColor : widget.leftColor;

    if (label == null || color == null || _offset.dx == 0) {
      return const SizedBox.shrink();
    }

    final opacity =
        (_offset.dx.abs() / _dismissThreshold).clamp(0.0, 1.0).toDouble();

    return Positioned(
      top: 20,
      left: isRight ? null : 20,
      right: isRight ? 20 : null,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: isRight ? -0.2 : 0.2,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 3),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        AnimatedOpacity(
          opacity: widget.enabled ? 1 : 0,
          duration:
          const Duration(milliseconds: 250),
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Text(
              widget.hintText,
              textAlign: TextAlign.center,
            ),
          ),
        ),

        Expanded(
          child: GestureDetector(

            behavior:
            HitTestBehavior.translucent,

            onHorizontalDragUpdate:
            widget.enabled
                ? (details) {

              setState(() {

                _offset += Offset(
                  details.delta.dx,
                  0,
                );
              });
            }
                : null,

            onHorizontalDragEnd:
            widget.enabled
                ? (_) {

              if (_offset.dx.abs() >=
                  _dismissThreshold) {
                _animateDismiss();
              } else {
                _animateBack();
              }
            }
                : null,

            child: Center(
              child: AnimatedOpacity(
                duration:
                const Duration(
                  milliseconds: 150,
                ),
                opacity:
                _animatingAway
                    ? 0.7
                    : 1,
                child:
                Transform.translate(
                  offset: _offset,
                  child: Transform.rotate(
                    angle: _rotation,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        widget.item.child,
                        _buildStamp(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}