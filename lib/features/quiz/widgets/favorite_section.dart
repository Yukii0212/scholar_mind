import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/providers/library_provider.dart';
import '../../notes/domain/library_folder.dart';

class FavoriteSection extends ConsumerWidget {
  const FavoriteSection({
    super.key,
    required this.onFolderOpened,
  });

  final ValueChanged<LibraryFolder> onFolderOpened;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteFoldersAsync = ref.watch(
      favoriteFoldersProvider,
    );

    final favoriteNotesAsync = ref.watch(
      favoriteNotesProvider,
    );

    return favoriteFoldersAsync.when(
      data: (favoriteFolders) {
        return favoriteNotesAsync.when(
          data: (favoriteNotes) {
            final supportedFavoriteNotes = favoriteNotes.where(
                  (note) {
                final extension = note.extension.toLowerCase();

                return extension == 'pdf' ||
                    extension == 'ppt' ||
                    extension == 'pptx';
              },
            ).toList();

            if (favoriteFolders.isEmpty &&
                supportedFavoriteNotes.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    8,
                  ),
                  child: Text(
                    'Favourites',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ),

                ...favoriteFolders.map(
                      (folder) => Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(folder.name),
                      trailing: const Icon(Icons.star),
                      onTap: () => onFolderOpened(folder),
                    ),
                  ),
                ),

                ...supportedFavoriteNotes.map(
                      (note) => Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.description_outlined,
                      ),
                      title: Text(note.name),
                      subtitle: Text(
                        note.extension.toUpperCase(),
                      ),
                      trailing: const Icon(Icons.star),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Divider(),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}