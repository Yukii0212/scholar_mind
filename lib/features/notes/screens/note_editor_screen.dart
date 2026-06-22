import 'package:flutter/material.dart';

class NoteEditorScreen extends StatelessWidget {
  const NoteEditorScreen({
    super.key,
    required this.noteId,
    required this.noteTitle,
    required this.content,
  });

  final String noteId;
  final String noteTitle;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(noteTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(content),
      ),
    );
  }
}