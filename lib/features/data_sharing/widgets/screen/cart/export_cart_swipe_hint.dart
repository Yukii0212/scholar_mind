import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/preferences/export_preferences.dart';

class ExportCartSwipeHint extends StatefulWidget {
  const ExportCartSwipeHint({
    super.key,
  });

  @override
  State<ExportCartSwipeHint> createState() =>
      _ExportCartSwipeHintState();
}

class _ExportCartSwipeHintState
    extends State<ExportCartSwipeHint> {
  bool _visible = false;
  bool _loaded = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final shouldShow =
    await ExportPreferences.shouldShowSwipeHint();

    if (!mounted) {
      return;
    }

    setState(() {
      _loaded = true;
      _visible = shouldShow;
    });

    if (shouldShow) {
      _timer = Timer(
        const Duration(seconds: 5),
        _dismiss,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    _timer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _visible = false;
    });
  }

  Future<void> _dismissForever() async {
    await ExportPreferences.dismissSwipeHint();
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 300,
      ),
      transitionBuilder: (
          child,
          animation,
          ) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      child: !_visible
          ? const SizedBox.shrink()
          : Dismissible(
        key: const ValueKey(
          'export_cart_swipe_hint',
        ),
        direction:
        DismissDirection.horizontal,
        onDismissed: (_) => _dismiss(),
        child: Card(
          key: const ValueKey(
            'hint_card',
          ),
          elevation: 0,
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.92),
          child: Padding(
            padding:
            const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.swipe_rounded,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Text(
                        'Swipe left or right on any item to remove it from your export cart.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Align(
                  alignment:
                  Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                    _dismissForever,
                    child: const Text(
                      "Don't show again",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}