import 'package:flutter/material.dart';
import '../domain/study_material_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/domain/library_folder.dart';
import '../widgets/library_browser.dart';
import '../domain/material_browser_mode.dart';
import '../widgets/favorite_browser.dart';

class StudyMaterialPickerScreen extends ConsumerStatefulWidget {
  const StudyMaterialPickerScreen({
    super.key,
    required this.type,
    this.initialSelection = const {},
  });

  final StudyMaterialType type;

  final Set<String> initialSelection;

  @override
  ConsumerState<StudyMaterialPickerScreen> createState() =>
      _StudyMaterialPickerScreenState();
}


class _StudyMaterialPickerScreenState
    extends ConsumerState<StudyMaterialPickerScreen> {

  String _libraryFolderId = LibraryFolder.rootId;

  final List<LibraryFolder> _libraryFolderStack = [];

  String _favoriteFolderId = LibraryFolder.rootId;

  final List<LibraryFolder> _favoriteFolderStack = [];

  MaterialBrowserMode _browserMode =
      MaterialBrowserMode.library;

  late final Set<String> _selectedNoteIds;

  @override
  void initState() {
    super.initState();

    _selectedNoteIds = {
      ...widget.initialSelection,
    };
  }

  void _toggleLibrarySelectAll(
      List<String> ids,
      ) {
    _toggleSelectAll(ids);
  }

  void _toggleFavoriteSelectAll(
      List<String> ids,
      ) {
    _toggleSelectAll(ids);
  }

  void _toggleSelectAll(
      List<String> ids,
      ) {
    setState(() {
      final allSelected = ids.every(
        _selectedNoteIds.contains,
      );

      if (allSelected) {
        _selectedNoteIds.removeAll(ids);
        return;
      }

      var remaining =
          30 - _selectedNoteIds.length;

      for (final id in ids) {
        if (_selectedNoteIds.contains(id)) {
          continue;
        }

        if (remaining == 0) {
          break;
        }

        _selectedNoteIds.add(id);
        remaining--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final folderStack =
    _browserMode == MaterialBrowserMode.library
        ? _libraryFolderStack
        : _favoriteFolderStack;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (widget.type) {
            StudyMaterialType.lectureNotes => 'Lecture Notes',
            StudyMaterialType.pastYearQuestions => 'Past Year Questions',
          },
        ),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<MaterialBrowserMode>(
              segments: const [
                ButtonSegment(
                  value: MaterialBrowserMode.library,
                  label: Text('Library'),
                ),
                ButtonSegment(
                  value: MaterialBrowserMode.favourites,
                  label: Text('Favorites'),
                ),
              ],
              selected: {_browserMode},
              onSelectionChanged: (selection) {
                setState(() {
                  _browserMode = selection.first;
                });
              },
            ),
          ),

          if ((_browserMode == MaterialBrowserMode.library
              ? _libraryFolderStack
              : _favoriteFolderStack)
              .isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_browserMode == MaterialBrowserMode.library) {
                          _libraryFolderStack.clear();
                          _libraryFolderId = LibraryFolder.rootId;
                        } else {
                          _favoriteFolderStack.clear();
                          _favoriteFolderId = LibraryFolder.rootId;
                        }
                      });
                    },
                    child: Text(
                      _browserMode == MaterialBrowserMode.library
                          ? 'Notes'
                          : 'Favorites',
                    ),
                  ),

    for (var i = 0; i < folderStack.length; i++) ...[
                    const Icon(Icons.chevron_right, size: 18),

                    TextButton(
                      onPressed: () {
                        setState(() {
    folderStack.removeRange(
    i + 1,
    folderStack.length,
    );

    if (_browserMode == MaterialBrowserMode.library) {
    _libraryFolderId = folderStack.isEmpty
    ? LibraryFolder.rootId
        : folderStack.last.id;
    } else {
    _favoriteFolderId = folderStack.isEmpty
    ? LibraryFolder.rootId
        : folderStack.last.id;
    }
                        });
                      },
                      child: Text(folderStack[i].name),
                    ),
                  ],
                ],
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _browserMode.index,
              children: [
                LibraryBrowser(
                  onToggleSelectAll:
                  _toggleLibrarySelectAll,
                  selectedNoteIds: _selectedNoteIds,
                  onNoteSelectionChanged: (noteId, selected) {
                    setState(() {
                      if (selected) {
                        _selectedNoteIds.add(noteId);
                      } else {
                        _selectedNoteIds.remove(noteId);
                      }
                    });
                  },
                  currentFolderId: _libraryFolderId,
                  folderStack: _libraryFolderStack,
                  onFolderOpened: (folder) {
                    setState(() {
                      _libraryFolderStack.add(folder);
                      _libraryFolderId = folder.id;
                    });
                  },
                ),

                FavoriteBrowser(
                  onToggleSelectAll:
                  _toggleFavoriteSelectAll,
                  selectedNoteIds: _selectedNoteIds,
                  onNoteSelectionChanged: (noteId, selected) {
                    setState(() {
                      if (selected) {
                        _selectedNoteIds.add(noteId);
                      } else {
                        _selectedNoteIds.remove(noteId);
                      }
                    });
                  },
                  currentFolderId: _favoriteFolderId,
                  folderStack: _favoriteFolderStack,
                  onFolderOpened: (folder) {
                    setState(() {
                      _favoriteFolderStack.add(folder);
                      _favoriteFolderId = folder.id;
                    });
                  },
                ),
              ],
            ),
          ),

          SafeArea(
            top: false,
            minimum: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedNoteIds.isEmpty
                    ? null
                    : () {
                  Navigator.pop(
                    context,
                    _selectedNoteIds,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    _selectedNoteIds.isEmpty
                        ? switch (widget.type) {
                      StudyMaterialType.lectureNotes =>
                      'Select lecture notes',
                      StudyMaterialType.pastYearQuestions =>
                      'Select past year questions',
                    }
                        : 'Done (${_selectedNoteIds.length} Selected)',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}