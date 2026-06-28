import 'package:flutter/material.dart';

import '../../notes/domain/note_item.dart';

class SelectionManagerScreen extends StatefulWidget {
  const SelectionManagerScreen({
    super.key,
    required this.title,
    required this.selectedNotes,
  });

  final String title;

  final List<NoteItem> selectedNotes;

  @override
  State<SelectionManagerScreen> createState() =>
      _SelectionManagerScreenState();
}

class _SelectionManagerScreenState
    extends State<SelectionManagerScreen> {

  late final Set<String> _selectedIds;

  final List<NoteItem> _deselectedNotes = [];

  @override
  void initState() {
    super.initState();

    _selectedIds = widget.selectedNotes
        .map((e) => e.id)
        .toSet();
  }

  void _toggle(NoteItem note) {
    setState(() {
      if (_selectedIds.remove(note.id)) {
        _deselectedNotes.add(note);
      } else {
        _selectedIds.add(note.id);
        _deselectedNotes.removeWhere(
              (e) => e.id == note.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedNotes
        .where(
          (e) => _selectedIds.contains(e.id),
    )
        .toList();

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

                if (selected.isNotEmpty) ...[
                  Text(
                    'Currently Selected',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),

                  const SizedBox(height: 12),

                  ...selected.map(
                        (note) => CheckboxListTile(
                      value: true,
                      title: Text(note.name),
                      onChanged: (_) =>
                          _toggle(note),
                    ),
                  ),
                ],

                if (_deselectedNotes
                    .isNotEmpty) ...[
                  const SizedBox(height: 24),

                  Text(
                    'Deselected This Session',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),

                  const SizedBox(height: 12),

                  ..._deselectedNotes.map(
                        (note) =>
                        CheckboxListTile(
                          value: false,
                          title:
                          Text(note.name),
                          onChanged: (_) =>
                              _toggle(note),
                        ),
                  ),
                ],
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
                  'Done (${_selectedIds.length} Selected)',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}