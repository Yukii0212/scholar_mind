import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/domain/library_folder.dart';
import '../../notes/providers/library_provider.dart';

class LibraryBrowser extends ConsumerWidget {
  const LibraryBrowser({
    super.key,
    required this.currentFolderId,
    required this.folderStack,
    required this.onFolderOpened,
    required this.selectedNoteIds,
    required this.onNoteSelectionChanged,
    required this.onToggleSelectAll,
  });

  final String currentFolderId;
  final List<LibraryFolder> folderStack;
  final ValueChanged<LibraryFolder> onFolderOpened;
  final Set<String> selectedNoteIds;
  final void Function(
      String noteId,
      bool selected,
      ) onNoteSelectionChanged;

  final void Function(
      List<String> ids,
      ) onToggleSelectAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(
      childFoldersProvider(currentFolderId),
    );

    final notesAsync = ref.watch(
      notesInFolderProvider(currentFolderId),
    );

    return foldersAsync.when(
      data: (folders) {
        return notesAsync.when(
          data: (notes) {
            final supportedNotes = notes.where(
                  (note) =>
              note.extension.toLowerCase() == 'pdf' ||
                  note.extension.toLowerCase() == 'ppt' ||
                  note.extension.toLowerCase() == 'pptx',
            ).toList();

            if (folders.isEmpty && supportedNotes.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'This folder is empty.',
                    ),
                    SizedBox(height: 8),
                    Text(
                      'There are no supported study materials in this folder.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [

                if (selectedNoteIds.length >= 30)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: Card(
                      color: Theme.of(context)
                          .colorScheme
                          .errorContainer,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Maximum of 30 study materials can be selected.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                ...folders.map(
                      (folder) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(folder.name),
                      trailing: folder.isFavorite
                          ? const Icon(Icons.star)
                          : const Icon(Icons.chevron_right),
                      onTap: () => onFolderOpened(folder),
                    ),
                  ),
                ),

                ...supportedNotes.map(
                      (note) => Card(
                        child: ListTile(
                          onTap: () {
                            final isSelected =
                            selectedNoteIds.contains(note.id);

                            onNoteSelectionChanged(
                              note.id,
                              !isSelected,
                            );
                          },
                          leading: IgnorePointer(
                            child: Checkbox(
                              value: selectedNoteIds.contains(note.id),
                              onChanged: (_) {},
                            ),
                          ),

                          enabled: selectedNoteIds.contains(note.id) ||
                              selectedNoteIds.length < 30,
                      title: Text(note.name),
                      subtitle: Text(
                        note.extension.toUpperCase(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () =>
          const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text(error.toString())),
        );
      },
      loading: () =>
      const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text(error.toString())),
    );
  }
}