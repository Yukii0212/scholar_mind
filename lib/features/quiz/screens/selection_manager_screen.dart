import 'package:flutter/material.dart';

import '../../notes/domain/note_item.dart';

class SelectionManagerScreen extends StatefulWidget {
  const SelectionManagerScreen({
    super.key,
    required this.title,
    required this.selectedNotes,
    required this.onAddMore,
  });

  final String title;

  final List<NoteItem> selectedNotes;

  /// Opens the full material picker (browsing the whole library, not just
  /// what's already selected) seeded with the current selection, and
  /// returns the updated selection -- or null if the user backed out
  /// without changing anything. This screen only ever sees the notes
  /// already selected, so adding anything new has to go through this.
  final Future<Set<String>?> Function(Set<String> currentSelection)
  onAddMore;

  @override
  State<SelectionManagerScreen> createState() =>
      _SelectionManagerScreenState();
}

class _SelectionManagerScreenState
    extends State<SelectionManagerScreen> {

  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();

    _selectedIds = widget.selectedNotes
        .map((e) => e.id)
        .toSet();
  }

  Future<void> _addMore() async {
    final updated = await widget.onAddMore(_selectedIds);

    if (updated == null || !mounted) {
      return;
    }

    // This screen only ever knows the NoteItems it was handed, so it can't
    // render a name for anything newly added -- hand the merged selection
    // straight back to the caller instead of trying to reflect it here.
    Navigator.pop(context, updated);
  }

  void _toggle(NoteItem note) {
    setState(() {
      if (_selectedIds.contains(note.id)) {
        _selectedIds.remove(note.id);
      } else {
        _selectedIds.add(note.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allNotes = widget.selectedNotes;

    final allSelected =
        _selectedIds.length ==
            allNotes.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [

          Expanded(
            child: ListView(
              padding:
              const EdgeInsets.all(16),
              children: [

                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add More'),
                      onPressed: _addMore,
                    ),
                    FilledButton.tonalIcon(
                      icon: Icon(
                        allSelected
                            ? Icons.deselect
                            : Icons.select_all,
                      ),
                      label: Text(
                        allSelected
                            ? 'Deselect All'
                            : 'Select All',
                      ),
                      onPressed: () {
                        setState(() {
                          if (allSelected) {
                            _selectedIds.clear();
                          } else {
                            _selectedIds
                              ..clear()
                              ..addAll(
                                allNotes.map(
                                      (e) => e.id,
                                ),
                              );
                          }
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ...allNotes.map(
                      (note) => CheckboxListTile(
                    value: _selectedIds.contains(
                      note.id,
                    ),
                    title: Text(note.name),
                    onChanged: (_) =>
                        _toggle(note),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            minimum:
            const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    _selectedIds,
                  );
                },
                child: Text(
                  'Done (${_selectedIds.length}/${allNotes.length})',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}