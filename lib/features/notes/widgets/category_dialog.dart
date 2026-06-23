import 'package:flutter/material.dart';
import '../domain/note_category.dart';

class CategoryDialog extends StatelessWidget {
  const CategoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Choose note category'),
      children: [
        for (final category in NoteCategory.values)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, category),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(category.label),
            ),
          ),
      ],
    );
  }
}