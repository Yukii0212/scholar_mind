import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/flashcard_provider.dart';

class FlashcardTrashSection extends ConsumerWidget {
  const FlashcardTrashSection({super.key});

  Future<void> _restoreAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore everything?'),
        content: const Text(
          'All folders and flashcard sets currently in the Trash will be restored.\n\n'
          'Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Restore All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(flashcardLibraryActionControllerProvider.notifier)
        .restoreAll();
  }

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete everything?'),
        content: const Text(
          'Everything in the Trash will be permanently deleted.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(flashcardLibraryActionControllerProvider.notifier)
        .permanentlyDeleteAll();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedFoldersAsync = ref.watch(flashcardDeletedFoldersProvider);
    final deletedSetsAsync = ref.watch(flashcardDeletedSetsProvider);

    final actionController =
        ref.read(flashcardLibraryActionControllerProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Trash',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                PopupMenuButton<String>(
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'restore_all',
                      child: Text('Restore All'),
                    ),
                    PopupMenuItem(
                      value: 'delete_all',
                      child: Text('Empty Trash'),
                    ),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'restore_all':
                        await _restoreAll(context, ref);
                        break;
                      case 'delete_all':
                        await _deleteAll(context, ref);
                        break;
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            deletedFoldersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Failed to load folders.'),
              data: (folders) {
                if (folders.isEmpty) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Folders',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...folders.map(
                      (folder) => ListTile(
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(folder.name),
                        subtitle: const Text('Folder'),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'restore',
                              child: Text('Restore'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Permanently'),
                            ),
                          ],
                          onSelected: (value) async {
                            switch (value) {
                              case 'restore':
                                await actionController.restoreFolder(folder);
                                break;

                              case 'delete':
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Delete permanently?'),
                                    content: const Text(
                                      'This folder, all child folders, and all flashcard sets inside it will be permanently deleted.\n\n'
                                      'This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed != true) return;

                                await actionController
                                    .permanentlyDeleteFolder(folder);
                                break;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            deletedSetsAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const Text('Failed to load flashcard sets.'),
              data: (sets) {
                if (sets.isEmpty) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flashcard Sets',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...sets.map(
                      (set) => ListTile(
                        leading: const Icon(Icons.style_outlined),
                        title: Text(set.name),
                        subtitle: const Text('Flashcard Set'),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'restore',
                              child: Text('Restore'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Permanently'),
                            ),
                          ],
                          onSelected: (value) async {
                            switch (value) {
                              case 'restore':
                                await actionController.restoreSet(set);
                                break;

                              case 'delete':
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Delete permanently?'),
                                    content: const Text(
                                      'This flashcard set will be permanently deleted.\n\n'
                                      'This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed != true) break;

                                await actionController.permanentlyDeleteSet(set);
                                break;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            if ((deletedFoldersAsync.valueOrNull?.isEmpty ?? true) &&
                (deletedSetsAsync.valueOrNull?.isEmpty ?? true))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Trash is empty.')),
              ),
          ],
        ),
      ),
    );
  }
}
