import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../core/theme/app_design.dart';
import '../../../core/widgets/collapsible_breadcrumb.dart';
import '../domain/flashcard_folder.dart';
import '../domain/flashcard_library_section.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/flashcard_folder_dialogs.dart';
import '../widgets/flashcard_library_section_widget.dart';
import '../widgets/flashcard_trash_section.dart';
import 'flashcard_set_editor_screen.dart';
import 'generate_flashcards_screen.dart';

class FlashcardLibraryScreen extends ConsumerStatefulWidget {
  const FlashcardLibraryScreen({super.key});

  @override
  ConsumerState<FlashcardLibraryScreen> createState() =>
      _FlashcardLibraryScreenState();
}

class _FlashcardLibraryScreenState
    extends ConsumerState<FlashcardLibraryScreen> {
  final List<FlashcardFolder> _folderStack = [];

  FlashcardLibrarySection _section = FlashcardLibrarySection.library;

  String get _folderId =>
      _folderStack.isEmpty ? FlashcardFolder.rootId : _folderStack.last.id;

  void _openFolder(FlashcardFolder folder) {
    setState(() {
      _section = FlashcardLibrarySection.library;

      if (_folderStack.isEmpty || _folderStack.last.id != folder.id) {
        _folderStack.add(folder);
      }
    });
  }

  void _openBreadcrumb(int index) {
    setState(() {
      if (index < 0) {
        _folderStack.clear();
      } else {
        _folderStack.removeRange(index + 1, _folderStack.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRoot = _folderId == FlashcardFolder.rootId;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.auto_awesome_rounded),
            label: 'Generate Flashcards',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GenerateFlashcardsScreen(),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.style_outlined),
            label: 'Create Set',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FlashcardSetEditorScreen(),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.create_new_folder),
            label: 'New Folder',
            onTap: () async {
              final folderName = await showDialog<String>(
                context: context,
                builder: (_) => const CreateFlashcardFolderDialog(),
              );

              if (folderName == null) return;
              if (!context.mounted) return;

              await ref
                  .read(flashcardLibraryActionControllerProvider.notifier)
                  .createFolder(parentId: _folderId, name: folderName);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScholarSectionHeader(
                title: isRoot
                    ? (_section == FlashcardLibrarySection.trash
                        ? 'Trash'
                        : 'Flashcards')
                    : 'Flashcards',
                subtitle: isRoot
                    ? (_section == FlashcardLibrarySection.trash
                        ? 'Deleted flashcard sets'
                        : 'Create sets, revise quickly, and generate from notes')
                    : 'Create sets, revise quickly, and generate from notes',
              ),

              const SizedBox(height: 12),

              CollapsibleBreadcrumb(
                homeLabel: 'My Flashcards',
                homeIcon: Icons.home_outlined,
                segments: [
                  for (final folder in _folderStack) folder.name,
                ],
                onPressed: _openBreadcrumb,
              ),

              const SizedBox(height: 12),
            ],
          ),

          const SizedBox(height: 24),

          if (isRoot) ...[
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<FlashcardLibrarySection>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: FlashcardLibrarySection.library,
                    icon: Icon(Icons.folder_outlined),
                    label: Text('Library'),
                  ),
                  ButtonSegment(
                    value: FlashcardLibrarySection.trash,
                    icon: Icon(Icons.delete_outline),
                    label: Text('Trash'),
                  ),
                ],
                selected: {_section},
                onSelectionChanged: (selection) {
                  setState(() => _section = selection.first);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          switch (isRoot ? _section : FlashcardLibrarySection.library) {
            FlashcardLibrarySection.library => FlashcardLibrarySectionWidget(
                folderId: _folderId,
                onOpenFolder: _openFolder,
              ),
            FlashcardLibrarySection.trash => const FlashcardTrashSection(),
          },

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
