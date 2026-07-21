import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../domain/quiz_enums.dart';
import '../domain/quiz_folder.dart';

class QuizFolderCard extends StatelessWidget {
  const QuizFolderCard({
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

  final QuizFolder folder;
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
                  isArchivedSection ? 'Archived quiz folder' : 'Quiz folder',
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
          PopupMenuButton<QuizItemAction>(
            onSelected: (action) {
              switch (action) {
                case QuizItemAction.rename:
                  onRename();
                  return;
                case QuizItemAction.move:
                  onMove();
                  return;
                case QuizItemAction.favorite:
                  onToggleFavorite();
                  return;
                case QuizItemAction.archive:
                  onToggleArchived();
                  return;
                case QuizItemAction.trash:
                  onDelete();
                  return;
                case QuizItemAction.restore:
                  onRestore();
                  return;
                case QuizItemAction.permanentDelete:
                  onPermanentDelete();
                  return;
              }
            },
            itemBuilder: (context) {
              if (isTrashSection) {
                return const [
                  PopupMenuItem(
                    value: QuizItemAction.restore,
                    child: Text('Restore'),
                  ),
                  PopupMenuItem(
                    value: QuizItemAction.permanentDelete,
                    child: Text('Delete Permanently'),
                  ),
                ];
              }

              return [
                const PopupMenuItem(
                  value: QuizItemAction.rename,
                  child: Text('Rename'),
                ),
                if (!isArchivedSection)
                  const PopupMenuItem(
                    value: QuizItemAction.move,
                    child: Text('Move'),
                  ),
                PopupMenuItem(
                  value: QuizItemAction.favorite,
                  child: Text(
                    folder.isFavorite
                        ? 'Remove favourite'
                        : 'Add to favourites',
                  ),
                ),
                PopupMenuItem(
                  value: QuizItemAction.archive,
                  child: Text(isArchivedSection ? 'Restore' : 'Archive'),
                ),
                const PopupMenuItem(
                  value: QuizItemAction.trash,
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
