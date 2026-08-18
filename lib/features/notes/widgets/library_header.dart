import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../../../core/widgets/collapsible_breadcrumb.dart';
import '../../help/widgets/help_anchor.dart';
import '../domain/library_enums.dart';
import '../domain/library_folder.dart';

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
  });

  final LibrarySection section;
  final List<LibraryFolder> folderStack;
  final bool isBusy;
  final ValueChanged<LibrarySection> onSectionChanged;
  final ValueChanged<int> onBreadcrumbPressed;
  final VoidCallback onCreateFolder;
  final VoidCallback onCreateNote;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScholarSectionHeader(
          title: _title,
          subtitle: _subtitle,
          trailing: null,
        ),

        const Gap(12),

        if (folderStack.isNotEmpty)
          CollapsibleBreadcrumb(
            homeLabel: section == LibrarySection.favorites
                ? 'Favorites'
                : 'Library',
            homeIcon: section == LibrarySection.favorites
                ? Icons.star_outline
                : Icons.home_outlined,
            segments: [
              for (final folder in folderStack) folder.name,
            ],
            onPressed: onBreadcrumbPressed,
          )
        else
          const SizedBox(height: 48),

        const Gap(16),

        SizedBox(
          width: double.infinity,
          child: HelpAnchor(
            pageId: '/notes',
            anchorId: 'library-section-tabs',
            child: SegmentedButton<LibrarySection>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: LibrarySection.browse,
                  icon: Icon(Icons.folder_outlined),
                  tooltip: 'Library',
                ),
                ButtonSegment(
                  value: LibrarySection.favorites,
                  icon: Icon(Icons.star_outline),
                  tooltip: 'Favorites',
                ),
                ButtonSegment(
                  value: LibrarySection.archived,
                  icon: Icon(Icons.archive_outlined),
                  tooltip: 'Archived',
                ),
                ButtonSegment(
                  value: LibrarySection.trash,
                  icon: Icon(Icons.delete_outline),
                  tooltip: 'Trash',
                ),
              ],
              selected: {section},
              onSelectionChanged: isBusy
                  ? null
                  : (selection) => onSectionChanged(selection.first),
            ),
          ),
        ),
      ],
    );
  }

  String get _title {
    if (folderStack.isNotEmpty) return folderStack.last.name;

    return switch (section) {
      LibrarySection.browse => 'Notes',
      LibrarySection.favorites => 'Favorites',
      LibrarySection.archived => 'Archived',
      LibrarySection.trash => 'Deleted',
    };
  }

  String get _subtitle => switch (section) {
        LibrarySection.browse => 'Organize and access your study materials',
        LibrarySection.favorites => 'Pinned notes and folders',
        LibrarySection.archived => 'Stored folders outside your active library',
        LibrarySection.trash => 'Restore or permanently remove deleted items',
      };
}
