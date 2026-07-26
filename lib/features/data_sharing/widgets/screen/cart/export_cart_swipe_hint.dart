import 'dart:async';

import 'package:flutter/material.dart';

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
  bool _visible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 5),
          () {
        if (mounted) {
          setState(() {
            _visible = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    _timer?.cancel();

    setState(() {
      _visible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        style: Theme.of(
                            context)
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
                    onPressed: () {
                      // TODO: Save preference.
                      _dismiss();
                    },
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