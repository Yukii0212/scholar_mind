import 'package:flutter/material.dart';

class ExportCartDeleteButton
    extends StatelessWidget {
  const ExportCartDeleteButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
        ),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}