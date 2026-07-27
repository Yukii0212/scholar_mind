import 'package:flutter/material.dart';

class ExportCartIconContainer
    extends StatelessWidget {
  const ExportCartIconContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(16),
        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: .10),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}