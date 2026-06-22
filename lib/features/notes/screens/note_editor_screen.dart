import 'dart:async';

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

  Timer? _autoSaveTimer;

  String _saveStatus = 'Saved';

  @override
  void initState() {
    super.initState();

    _draftKey = 'draft_${widget.noteId}';

    _controller = TextEditingController(
      text: widget.content,
    );

    _loadDraft();

    _controller.addListener(() async {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _draftKey,
        _controller.text,
      );

      if (mounted) {
        setState(() {
          _hasChanges = true;
          _saveStatus = 'Unsaved';
        });
      }

      _autoSaveTimer?.cancel();

      _autoSaveTimer = Timer(
        const Duration(seconds: 1),
        _autoSave,
      );
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
    _autoSaveTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_draftKey);
  }

  Future<void> _autoSave() async {
    if (!_hasChanges) return;

    if (mounted) {
      setState(() {
        _saveStatus = 'Saving...';
      });
    }

    final success = await ref
        .read(libraryActionControllerProvider.notifier)
        .updateInternalNote(
      noteId: widget.noteId,
      content: _controller.text,
    );

    if (!mounted) return;

    if (success) {
      await _clearDraft();

      setState(() {
        _hasChanges = false;
        _saveStatus = 'Saved';
      });
    } else {
      setState(() {
        _saveStatus = 'Failed to Save';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.noteTitle),
            Text(
              _saveStatus,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
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