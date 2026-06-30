import 'package:flutter/material.dart';

class GenerateQuizButton extends StatelessWidget {
  const GenerateQuizButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.auto_awesome),
      label: const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Text('Generate AI Quiz'),
      ),
    );
  }
}