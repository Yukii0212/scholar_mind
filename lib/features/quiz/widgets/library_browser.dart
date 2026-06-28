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
  });

  final String currentFolderId;
  final List<LibraryFolder> folderStack;
  final ValueChanged<LibraryFolder> onFolderOpened;

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
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
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

                ...notes
                    .where(
                      (note) =>
                  note.extension.toLowerCase() == 'pdf' ||
                      note.extension.toLowerCase() == 'ppt' ||
                      note.extension.toLowerCase() == 'pptx',
                )
                    .map(
                      (note) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.description_outlined),
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