import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/library_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
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
  ConsumerState<NoteEditorScreen> createState() =>
      _NoteEditorScreenState();
}

class _NoteEditorScreenState
    extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _controller;

  bool _hasChanges = false;

  late final String _draftKey;

  @override
  void initState() {
    super.initState();

    _draftKey = 'draft_${widget.noteId}';

    _controller = TextEditingController(
      text: widget.content,
    );

    _loadDraft();

    _controller.addListener(() async {
      final changed = _controller.text != widget.content;
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _draftKey,
        _controller.text,
      );

      if (changed != _hasChanges) {
        setState(() {
          _hasChanges = changed;
        });
      }
    });
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();

    final draft = prefs.getString(_draftKey);

    if (draft == null || draft.isEmpty) {
      return;
    }

    if (!mounted) return;

    _controller.text = draft;

    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_draftKey);
  }

  Future<void> _saveNote() async {
    final success = await ref
        .read(libraryActionControllerProvider.notifier)
        .updateInternalNote(
      noteId: widget.noteId,
      content: _controller.text,
    );

    if (!mounted) return;

    if (success) {
      await _clearDraft();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved'),
        ),
      );

      setState(() {
        _hasChanges = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save note'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteTitle),
        actions: [
          TextButton.icon(
            onPressed: _hasChanges ? _saveNote : null,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _controller,
          expands: true,
          maxLines: null,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(
            hintText: 'Start typing...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}