import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/device_id_service.dart';
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
  bool _isReadOnly = false;

  late final String _draftKey;

  Timer? _autoSaveTimer;
  Timer? _heartbeatTimer;

  String _saveStatus = 'Saved';

  @override
  void initState() {
    super.initState();

    _draftKey = 'draft_${widget.noteId}';

    _controller = TextEditingController(
      text: widget.content,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final acquired = await ref
          .read(
        libraryActionControllerProvider.notifier,
      )
          .acquireNoteLock(
        noteId: widget.noteId,
      );

      print('Lock acquired: $acquired');

      if (!mounted) {
        return;
      }

      if (!acquired) {
        setState(() {
          _isReadOnly = true;
        });

        return;
      }

      _loadDraft();

      _heartbeatTimer = Timer.periodic(
        const Duration(seconds: 5),
            (_) async {
          await ref
              .read(
            libraryActionControllerProvider.notifier,
          )
              .heartbeatNoteLock(
            noteId: widget.noteId,
          );
        },
      );
    });

    _controller.addListener(() async {
      if (_isReadOnly) {
        return;
      }

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
    _heartbeatTimer?.cancel();
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
      body: Consumer(
        builder: (context, ref, _) {
          ref.watch(
            noteProvider(widget.noteId),
          ).whenData((note) async {
            print('STREAM UPDATE');
            print('lockedBy = ${note.lockedBy}');
            final deviceId =
            await DeviceIdService.getDeviceId();

            final isReadOnly =
                note.lockedBy != deviceId;

            if (_isReadOnly != isReadOnly &&
                mounted) {
              setState(() {
                _isReadOnly = isReadOnly;
              });

              if (isReadOnly) {
                _heartbeatTimer?.cancel();
              } else {
                _heartbeatTimer?.cancel();

                _heartbeatTimer = Timer.periodic(
                  const Duration(seconds: 5),
                      (_) {
                    ref
                        .read(
                      libraryActionControllerProvider
                          .notifier,
                    )
                        .heartbeatNoteLock(
                      noteId: widget.noteId,
                    );
                  },
                );
              }
            }

            if (!_hasChanges &&
                _controller.text != note.content) {
              _controller.value =
                  TextEditingValue(
                    text: note.content,
                    selection:
                    TextSelection.collapsed(
                      offset: note.content.length,
                    ),
                  );
            }
          });

          return Padding(
            padding:
            const EdgeInsets.all(16),
            child: Column(
                children: [
                if (_isReadOnly)
            Padding(
          padding: const EdgeInsets.only(
          bottom: 12,
          ),
          child: FilledButton.icon(
          onPressed: () async {
          final success = await ref
              .read(
          libraryActionControllerProvider
              .notifier,
          )
              .forceAcquireNoteLock(
          noteId: widget.noteId,
          );

          if (!success || !mounted) {
          return;
          }

          setState(() {
          _isReadOnly = false;
          });

          _heartbeatTimer?.cancel();

          _heartbeatTimer = Timer.periodic(
            const Duration(seconds: 5),
                (_) {
              ref
                  .read(
                libraryActionControllerProvider.notifier,
              )
                  .heartbeatNoteLock(
                noteId: widget.noteId,
              );
            },
          );
          },
          icon: const Icon(
          Icons.edit,
          ),
          label: const Text(
          'Resume Editing',
          ),
          ),
          ),
          Expanded(
          child: TextField(
          controller: _controller,
          readOnly: _isReadOnly,
              expands: true,
              maxLines: null,
              textAlignVertical:
              TextAlignVertical.top,
            decoration:
            InputDecoration(
              hintText: _isReadOnly
                  ? 'Read-only'
                  : 'Start typing...',
              border:
              const OutlineInputBorder(),
            ),
          ),
          ),
                ],
            ),
          );
        },
      ),
    );
  }
}