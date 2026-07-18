import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../domain/library_enums.dart';
import '../domain/library_folder.dart';

class FolderCard extends StatelessWidget {
  const FolderCard({
    super.key,
    required this.folder,
    required this.isArchivedSection,
    required this.isTrashSection,
    required this.onDelete,
    required this.onRestore,
    required this.onOpen,
    required this.onMove,
    required this.onRename,
    required this.onToggleFavorite,
    required this.onToggleArchived,
    required this.onPermanentDelete,
  });

  final LibraryFolder folder;
  final bool isTrashSection;
  final bool isArchivedSection;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onRestore;
  final VoidCallback onRename;
  final VoidCallback onMove;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleArchived;
  final VoidCallback onPermanentDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return ScholarPanel(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      onTap: isArchivedSection || isTrashSection ? null : onOpen,
      child: Row(
        children: [
          ScholarIconBadge(
            icon: isArchivedSection
                ? Icons.folder_off_outlined
                : Icons.folder_rounded,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folder.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Gap(4),
                Text(
                  isArchivedSection ? 'Archived folder' : 'Study folder',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                      ),
                ),
              ],
            ),
          ),
          if (folder.isFavorite)
            Icon(
              Icons.star_rounded,
              size: 18,
              color: palette.accent,
            ),
          PopupMenuButton<LibraryItemAction>(
            onSelected: (action) {
              switch (action) {
                case LibraryItemAction.rename:
                  onRename();
                  return;
                case LibraryItemAction.move:
                  onMove();
                  return;
                case LibraryItemAction.copy:
                  return;
                case LibraryItemAction.favorite:
                  onToggleFavorite();
                  return;
                case LibraryItemAction.archive:
                  onToggleArchived();
                  return;
                case LibraryItemAction.trash:
                  onDelete();
                  return;
                case LibraryItemAction.restore:
                  onRestore();
                  return;
                case LibraryItemAction.permanentDelete:
                  onPermanentDelete();
                  return;
              }
            },
            itemBuilder: (context) {
              if (isTrashSection) {
                return const [
                  PopupMenuItem(
                    value: LibraryItemAction.restore,
                    child: Text('Restore'),
                  ),
                  PopupMenuItem(
                    value: LibraryItemAction.permanentDelete,
                    child: Text('Delete Permanently'),
                  ),
                ];
              }

              return [
                const PopupMenuItem(
                  value: LibraryItemAction.rename,
                  child: Text('Rename'),
                ),
                if (!isArchivedSection)
                  const PopupMenuItem(
                    value: LibraryItemAction.move,
                    child: Text('Move'),
                  ),
                PopupMenuItem(
                  value: LibraryItemAction.favorite,
                  child: Text(
                    folder.isFavorite
                        ? 'Remove favourite'
                        : 'Add to favourites',
                  ),
                ),
                PopupMenuItem(
                  value: LibraryItemAction.archive,
                  child: Text(isArchivedSection ? 'Restore' : 'Archive'),
                ),
                const PopupMenuItem(
                  value: LibraryItemAction.trash,
                  child: Text('Move to Trash'),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
