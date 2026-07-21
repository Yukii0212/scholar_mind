import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../domain/note_item.dart';
import '../domain/library_enums.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onRename,
    required this.onToggleFavorite,
    required this.onDelete,
    required this.onMove,
    required this.onCopy,
    required this.isTrashSection,
    required this.onRestore,
    required this.onPermanentDelete,
  });

  final bool isTrashSection;
  final NoteItem note;
  final VoidCallback onTap;
  final VoidCallback onMove;
  final VoidCallback onRename;
  final VoidCallback onCopy;
  final VoidCallback onToggleFavorite;
  final VoidCallback onRestore;
  final VoidCallback onPermanentDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final fileColor = _fileColor(note.extension, context);

    return ScholarPanel(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
        leading: ScholarIconBadge(
          icon: _fileIcon(note.extension),
          color: fileColor,
        ),
        title: Text(
          note.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MetaChip(label: note.category.label, color: fileColor),
              _MetaChip(label: _formatBytes(note.sizeBytes)),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.isFavorite)
              Icon(Icons.star_rounded, color: palette.accent, size: 18),
            const Gap(2),
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
                    onCopy();
                    return;

                  case LibraryItemAction.favorite:
                    onToggleFavorite();
                    return;

                  case LibraryItemAction.archive:
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
                  const PopupMenuItem(
                    value: LibraryItemAction.move,
                    child: Text('Move'),
                  ),
                  const PopupMenuItem(
                    value: LibraryItemAction.copy,
                    child: Text('Copy'),
                  ),
                  PopupMenuItem(
                    value: LibraryItemAction.favorite,
                    child: Text(
                      note.isFavorite
                          ? 'Remove favourite'
                          : 'Add to favourites',
                    ),
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
      ),
    );
  }

  static IconData _fileIcon(String extension) {
    return switch (extension.toLowerCase()) {
      'pdf' => Icons.picture_as_pdf_outlined,
      'png' || 'jpg' || 'jpeg' => Icons.image_outlined,
      'ppt' || 'pptx' => Icons.slideshow_outlined,
      'doc' || 'docx' => Icons.description_outlined,
      _ => Icons.insert_drive_file_outlined,
    };
  }

  static Color _fileColor(String extension, BuildContext context) {
    final palette = context.scholarPalette;

    return switch (extension.toLowerCase()) {
      'pdf' => const Color(0xFFFF4D6D),
      'ppt' || 'pptx' => const Color(0xFFFF8C42),
      'png' || 'jpg' || 'jpeg' => const Color(0xFF37C7A3),
      'doc' || 'docx' => palette.brandStart,
      _ => palette.brandEnd,
    };
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: (color ?? palette.brandStart).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color ?? palette.brandEnd,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
