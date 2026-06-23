import 'package:flutter/material.dart';

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
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(_fileIcon(note.extension)),
        ),
        title: Text(note.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${note.category.label} • ${_formatBytes(note.sizeBytes)}',
        ),
        trailing: PopupMenuButton<LibraryItemAction>(
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

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}