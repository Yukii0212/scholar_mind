import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/flashcard_provider.dart';
import '../screens/flashcard_set_detail_screen.dart';
import 'flashcard_folder_picker_dialog.dart';

class FlashcardContinueSection extends ConsumerWidget {
  const FlashcardContinueSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSetsAsync = ref.watch(flashcardActiveSetsProvider);

    return activeSetsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (activeSets) {
        if (activeSets.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.check_circle_outline),
                    title: Text("You're all caught up!"),
                    subtitle: Text(
                      'You have no flashcard sets waiting to be studied.',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeSets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = activeSets[index];

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ExpansionTile(
                        leading: const Icon(Icons.play_circle_fill),
                        title: Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('${item.cardCount} flashcards • Not started yet'),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Study Now'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FlashcardSetDetailScreen(
                                      flashcardSet: item,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.drive_file_move),
                              label: const Text('Move'),
                              onPressed: () async {
                                final folders = await ref.read(
                                  flashcardAllFoldersProvider.future,
                                );

                                if (!context.mounted) return;

                                final destinationFolderId =
                                    await showDialog<String>(
                                  context: context,
                                  builder: (_) => FlashcardFolderPickerDialog(
                                    folders: folders,
                                  ),
                                );

                                if (destinationFolderId == null) return;

                                await ref
                                    .read(
                                      flashcardLibraryActionControllerProvider
                                          .notifier,
                                    )
                                    .moveSet(
                                      setId: item.id,
                                      destinationFolderId:
                                          destinationFolderId,
                                    );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.visibility_off_outlined),
                              label: const Text('Remove from Continue'),
                              onPressed: () async {
                                await ref
                                    .read(
                                      flashcardLibraryActionControllerProvider
                                          .notifier,
                                    )
                                    .toggleSetArchived(item);

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '"${item.name}" removed from Continue. '
                                      "It's still in your Library.",
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Delete Set?'),
                                    content: Text(
                                      'Move "${item.name}" to Trash?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                          dialogContext,
                                          false,
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(
                                          dialogContext,
                                          true,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed != true) return;

                                await ref
                                    .read(
                                      flashcardLibraryActionControllerProvider
                                          .notifier,
                                    )
                                    .softDeleteSet(item);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
