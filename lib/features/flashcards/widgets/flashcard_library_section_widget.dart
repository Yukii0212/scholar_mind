import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/flashcard_folder.dart';
import '../domain/flashcard_models.dart';
import '../providers/flashcard_provider.dart';
import '../screens/flashcard_set_detail_screen.dart';
import '../screens/flashcard_set_editor_screen.dart';
import 'flashcard_folder_picker_dialog.dart';

class FlashcardLibrarySectionWidget extends ConsumerWidget {
  const FlashcardLibrarySectionWidget({
    super.key,
    required this.folderId,
    required this.onOpenFolder,
  });

  final String folderId;
  final ValueChanged<FlashcardFolder> onOpenFolder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(flashcardSetsInFolderProvider(folderId));
    final foldersAsync = ref.watch(flashcardChildFoldersProvider(folderId));

    return setsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Unable to load flashcard sets: $error'),
      ),
      data: (sets) {
        final folders = foldersAsync.value ?? [];

        if (folders.isEmpty && sets.isEmpty) {
          return const _EmptyLibrary();
        }

        return Column(
          children: [
            for (final folder in folders) ...[
              _FolderTile(folder: folder, onOpen: onOpenFolder),
              const Gap(12),
            ],
            for (final flashcardSet in sets) ...[
              _SetTile(flashcardSet: flashcardSet),
              if (flashcardSet != sets.last) const Gap(12),
            ],
          ],
        );
      },
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return ScholarPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const ScholarIconBadge(icon: Icons.style_outlined, size: 58),
          const Gap(14),
          Text(
            'No flashcard sets yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Gap(6),
          Text(
            'Create a set manually or generate one from your notes.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: palette.textMuted),
          ),
        ],
      ),
    );
  }
}

class _FolderTile extends ConsumerWidget {
  const _FolderTile({required this.folder, required this.onOpen});

  final FlashcardFolder folder;
  final ValueChanged<FlashcardFolder> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScholarPanel(
      padding: const EdgeInsets.all(14),
      onTap: () => onOpen(folder),
      child: Row(
        children: [
          const ScholarIconBadge(icon: Icons.folder, size: 52),
          const Gap(14),
          Expanded(
            child: Text(
              folder.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'rename':
                  final controller = TextEditingController(text: folder.name);

                  final newName = await showDialog<String>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Rename Folder'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Folder Name',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(
                            dialogContext,
                            controller.text.trim(),
                          ),
                          child: const Text('Rename'),
                        ),
                      ],
                    ),
                  );

                  if (newName == null || newName.trim().isEmpty) return;

                  await ref
                      .read(flashcardLibraryActionControllerProvider.notifier)
                      .renameFolder(folderId: folder.id, name: newName);

                  break;

                case 'move':
                  final folders =
                      await ref.read(flashcardAllFoldersProvider.future);

                  if (!context.mounted) return;

                  final destinationFolderId = await showDialog<String>(
                    context: context,
                    builder: (_) => FlashcardFolderPickerDialog(
                      folders: folders,
                      excludeFolderId: folder.id,
                    ),
                  );

                  if (destinationFolderId == null) return;

                  final success = await ref
                      .read(flashcardLibraryActionControllerProvider.notifier)
                      .moveFolder(
                        folderId: folder.id,
                        destinationFolderId: destinationFolderId,
                      );

                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('That folder cannot be moved there.'),
                      ),
                    );
                  }

                  break;

                case 'delete':
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete Folder?'),
                      content: Text(
                        'Move "${folder.name}" to Trash? All of its subfolders and flashcard sets will be moved to Trash too.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true) return;

                  await ref
                      .read(flashcardLibraryActionControllerProvider.notifier)
                      .softDeleteFolder(folder);

                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rename', child: Text('Rename')),
              PopupMenuItem(value: 'move', child: Text('Move')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetTile extends ConsumerWidget {
  const _SetTile({required this.flashcardSet});

  final FlashcardSet flashcardSet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.scholarPalette;
    final userId = ref.watch(authStateProvider).valueOrNull?.uid;

    return ScholarPanel(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FlashcardSetDetailScreen(flashcardSet: flashcardSet),
        ),
      ),
      child: Row(
        children: [
          ScholarIconBadge(
            icon: flashcardSet.generationMethod ==
                    FlashcardGenerationMethod.aiGenerated
                ? Icons.auto_awesome_rounded
                : Icons.edit_outlined,
            size: 52,
            color: flashcardSet.generationMethod ==
                    FlashcardGenerationMethod.aiGenerated
                ? palette.brandStart
                : palette.brandEnd,
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flashcardSet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Gap(6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _SetPill('${flashcardSet.cardCount} flashcards'),
                    _SetPill(flashcardSet.generationMethod.label),
                    for (final tag in flashcardSet.tags.take(2)) _SetPill(tag),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          FlashcardSetEditorScreen(flashcardSet: flashcardSet),
                    ),
                  );
                  break;

                case 'move':
                  final folders =
                      await ref.read(flashcardAllFoldersProvider.future);

                  if (!context.mounted) return;

                  final destinationFolderId = await showDialog<String>(
                    context: context,
                    builder: (_) =>
                        FlashcardFolderPickerDialog(folders: folders),
                  );

                  if (destinationFolderId == null) return;

                  await ref
                      .read(flashcardLibraryActionControllerProvider.notifier)
                      .moveSet(
                        setId: flashcardSet.id,
                        destinationFolderId: destinationFolderId,
                      );

                  break;

                case 'delete':
                  if (userId == null) return;

                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete Set?'),
                      content: Text('Move "${flashcardSet.name}" to Trash?'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true) return;

                  await ref
                      .read(flashcardLibraryActionControllerProvider.notifier)
                      .softDeleteSet(flashcardSet);

                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'move', child: Text('Move')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetPill extends StatelessWidget {
  const _SetPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: palette.brandStart.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: palette.brandEnd,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
