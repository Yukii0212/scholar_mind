import 'package:flutter/material.dart';

class GenerateQuizButton extends StatelessWidget {
  const GenerateQuizButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: null,
      icon: Icon(Icons.auto_awesome),
      label: Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Text('Generate AI Quiz'),
      ),
    );
  }
}