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
        Text(
          'Notes',
          style: Theme.of(context)
              .textTheme
              .headlineMedium,
        ),

        const Gap(20),

        if (section == LibrarySection.browse) ...[

          Wrap(

            crossAxisAlignment:
            WrapCrossAlignment.center,

            spacing: 2,

            children: [

              TextButton.icon(

                onPressed: () =>
                    onBreadcrumbPressed(-1),

                icon: const Icon(
                  Icons.home_outlined,
                  size: 18,
                ),

                label: const Text(
                  'Home',
                ),

              ),

              for (var index = 0;
              index < folderStack.length;
              index++) ...[

                const Icon(
                  Icons.chevron_right,
                  size: 18,
                ),

                TextButton(

                  onPressed: () =>
                      onBreadcrumbPressed(index),

                  child: Text(
                    folderStack[index].name,
                  ),

                ),

              ],

            ],

          ),

          const Gap(20),

        ],

        SizedBox(

            width: double.infinity,

            child: SegmentedButton<LibrarySection>(

              showSelectedIcon: false,

          segments: const [

            ButtonSegment(

              value: LibrarySection.browse,

              icon: Icon(
                Icons.folder_outlined,
              ),

            ),

            ButtonSegment(

              value: LibrarySection.favorites,

              icon: Icon(
                Icons.star_outline,
              ),

            ),

            ButtonSegment(

              value: LibrarySection.archived,

              icon: Icon(
                Icons.archive_outlined,
              ),

            ),

            ButtonSegment(

              value: LibrarySection.trash,

              icon: Icon(
                Icons.delete_outline,
              ),

            ),

          ],
          selected: {section},
          onSelectionChanged:
          isBusy ? null : (selection) => onSectionChanged(selection.first),
        ),
        ),
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