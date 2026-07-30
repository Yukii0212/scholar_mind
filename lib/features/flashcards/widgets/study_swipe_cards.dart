import 'package:flutter/material.dart';

import 'study_swipe_card_item.dart';

class StudySwipeCards extends StatefulWidget {
  const StudySwipeCards({
    super.key,
    required this.item,
    required this.hintText,
    this.enabled = true,
  });

  final StudySwipeCardItem item;

  /// Shown above the card, e.g. "Swipe either way to skip" on the
  /// question or "Swipe right: I knew it • Swipe left: Didn't know it"
  /// on the answer — meaning changes with which side is showing, so the
  /// caller supplies it rather than this widget hardcoding one label.
  final String hintText;

  final bool enabled;

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
                    child:
                    widget.item.child,
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