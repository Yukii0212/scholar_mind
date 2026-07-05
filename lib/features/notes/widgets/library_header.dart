import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../domain/library_folder.dart';
import '../domain/library_enums.dart';

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

  final LibrarySection section;
  final List<LibraryFolder> folderStack;
  final bool isBusy;
  final ValueChanged<LibrarySection> onSectionChanged;
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
        Text('Notes', style: Theme.of(context).textTheme.headlineMedium),
        const Gap(4),
        Text(
          'Organise study material into folders and categories.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(20),
        SegmentedButton<LibrarySection>(
          segments: const [
            ButtonSegment(
              value: LibrarySection.browse,
              icon: Icon(Icons.folder_outlined),
              label: Text('Library'),
            ),
            ButtonSegment(
              value: LibrarySection.favorites,
              icon: Icon(Icons.star_outline),
              label: Text('Favourites'),
            ),
            ButtonSegment(
              value: LibrarySection.archived,
              icon: Icon(Icons.archive_outlined),
              label: Text('Archived'),
            ),
            ButtonSegment(
              value: LibrarySection.trash,
              icon: Icon(Icons.delete_outline),
              label: Text('Trash'),
            ),
          ],
          selected: {section},
          onSelectionChanged:
          isBusy ? null : (selection) => onSectionChanged(selection.first),
        ),
        if (section == LibrarySection.browse)
          const Gap(18),
        if (section == LibrarySection.trash) ...[
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