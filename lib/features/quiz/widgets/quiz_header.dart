import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../domain/quiz_enums.dart';

class LibraryHeader extends StatelessWidget {
  const LibraryHeader({
    super.key,
    required this.section,
    required this.folderStack,
    required this.isBusy,
    required this.onSectionChanged,
    required this.onBreadcrumbPressed,
    required this.onCreateFolder,
    required this.onCreateNote,
    required this.onUpload,
    required this.onRestoreAll,
    required this.onDeleteAll,
  });

  final QuizSection section;
  final List<QuizSection> folderStack;
  final bool isBusy;
  final ValueChanged<QuizSection> onSectionChanged;
  final ValueChanged<int> onBreadcrumbPressed;
  final VoidCallback onCreateFolder;
  final VoidCallback onCreateNote;
  final VoidCallback onUpload;
  final VoidCallback onRestoreAll;
  final VoidCallback onDeleteAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Quizzes', style: Theme.of(context).textTheme.headlineMedium),
        const Gap(4),
        Text(
          'Organise generated quizzes into folders.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(20),
        SegmentedButton<QuizSection>(
          segments: const [
            ButtonSegment(
              value: QuizSection.browse,
              icon: Icon(Icons.folder_outlined),
              label: Text('Library'),
            ),
            ButtonSegment(
              value: QuizSection.favorites,
              icon: Icon(Icons.star_outline),
              label: Text('Favourites'),
            ),
            ButtonSegment(
              value: QuizSection.archived,
              icon: Icon(Icons.archive_outlined),
              label: Text('Archived'),
            ),
            ButtonSegment(
              value: QuizSection.trash,
              icon: Icon(Icons.delete_outline),
              label: Text('Trash'),
            ),
          ],
          selected: {section},
          onSelectionChanged:
          isBusy ? null : (selection) => onSectionChanged(selection.first),
        ),
        if (section == QuizSection.browse) ...[
          const Gap(18),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            children: [
              TextButton.icon(
                onPressed: () => onBreadcrumbPressed(-1),
                icon: const Icon(Icons.home_outlined, size: 18),
                label: const Text('My Quizzes'),
              ),
              for (var index = 0; index < folderStack.length; index++) ...[
                const Icon(Icons.chevron_right, size: 18),
                TextButton(
                  onPressed: () => onBreadcrumbPressed(index),
                  child: Text(folderStack[index].name),
                ),
              ],
            ],
          ),
          const Gap(10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: isBusy ? null : onCreateFolder,
                icon: const Icon(Icons.create_new_folder_outlined),
                label: const Text('New folder'),
              ),
              FilledButton.icon(
                onPressed: isBusy ? null : onUpload,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Generate Quiz'),
              ),
            ],
          ),
        ],
        if (section == QuizSection.trash) ...[
          const Gap(18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: isBusy ? null : onRestoreAll,
                icon: const Icon(Icons.restore),
                label: const Text('Restore All'),
              ),
              FilledButton.icon(
                onPressed: isBusy ? null : onDeleteAll,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete All'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}