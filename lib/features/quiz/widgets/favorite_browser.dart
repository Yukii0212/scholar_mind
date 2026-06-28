import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/domain/library_folder.dart';
import '../../notes/providers/library_provider.dart';

class FavoriteBrowser extends ConsumerWidget {
  const FavoriteBrowser({
    super.key,
    required this.currentFolderId,
    required this.folderStack,
    required this.onFolderOpened,
  });

  final String currentFolderId;
  final List<LibraryFolder> folderStack;
  final ValueChanged<LibraryFolder> onFolderOpened;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool atFavoritesRoot =
        folderStack.isEmpty;

    final foldersAsync = atFavoritesRoot
        ? ref.watch(
      favoriteFoldersProvider,
    )
        : ref.watch(
      childFoldersProvider(currentFolderId),
    );

    final notesAsync = atFavoritesRoot
        ? ref.watch(
      favoriteNotesProvider,
    )
        : ref.watch(
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
                ...folders.map(
                      (folder) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(folder.name),
                      trailing: atFavoritesRoot
                          ? const Icon(Icons.star)
                          : const Icon(Icons.chevron_right),
                      onTap: () => onFolderOpened(folder),
                    ),
                  ),
                ),

                ...supportedNotes.map(
                      (note) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(note.name),
                      subtitle: Text(
                        note.extension.toUpperCase(),
                      ),
                      trailing: const Icon(Icons.star),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: Text(error.toString()),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        child: Text(error.toString()),
      ),
    );
  }
}