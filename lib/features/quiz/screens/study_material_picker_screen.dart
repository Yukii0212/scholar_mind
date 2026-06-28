import 'package:flutter/material.dart';
import '../domain/study_material_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/domain/library_folder.dart';
import '../../notes/providers/library_provider.dart';
import '../widgets/material_browser.dart';

class StudyMaterialPickerScreen extends ConsumerStatefulWidget {
  const StudyMaterialPickerScreen({
    super.key,
    required this.type,
  });

  final StudyMaterialType type;

  @override
  ConsumerState<StudyMaterialPickerScreen> createState() =>
      _StudyMaterialPickerScreenState();
}

class _StudyMaterialPickerScreenState
    extends ConsumerState<StudyMaterialPickerScreen> {

  String _currentFolderId = LibraryFolder.rootId;

  final List<LibraryFolder> _folderStack = [];

  @override
  Widget build(BuildContext context) {
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

          if (_folderStack.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _folderStack.clear();
                        _currentFolderId = LibraryFolder.rootId;
                      });
                    },
                    child: const Text('Notes'),
                  ),

                  for (var i = 0; i < _folderStack.length; i++) ...[
                    const Icon(Icons.chevron_right, size: 18),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          _folderStack.removeRange(
                            i + 1,
                            _folderStack.length,
                          );

                          _currentFolderId = _folderStack.isEmpty
                              ? LibraryFolder.rootId
                              : _folderStack.last.id;
                        });
                      },
                      child: Text(_folderStack[i].name),
                    ),
                  ],
                ],
              ),
            ),
          Expanded(
            child: MaterialBrowser(
              currentFolderId: _currentFolderId,
              folderStack: _folderStack,
              onFolderOpened: (folder) {
                setState(() {
                  _folderStack.add(folder);
                  _currentFolderId = folder.id;
                });
              },
            ),
          ),

          SafeArea(
            top: false,
            minimum: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Select at least one note'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}