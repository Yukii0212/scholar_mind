import 'package:flutter/material.dart';

import '../domain/library_folder.dart';

/// Picks a destination folder by drilling down one level at a time,
/// matching the study material picker's folder browsing -- not by
/// indenting an ever-deepening tree, which used to squeeze folder names
/// down to almost nothing (or an unreadable ellipsis) once a few levels
/// deep. "Move Here" always targets whichever folder is currently being
/// viewed.
class FolderPickerDialog extends StatefulWidget {
  const FolderPickerDialog({
    super.key,
    required this.folders,
    this.excludeFolderId,
  });

  final List<LibraryFolder> folders;
  final String? excludeFolderId;

  @override
  State<FolderPickerDialog> createState() =>
      _FolderPickerDialogState();
}

class _FolderPickerDialogState
    extends State<FolderPickerDialog> {
  final List<LibraryFolder> _stack = [];

  String get _currentFolderId =>
      _stack.isEmpty ? LibraryFolder.rootId : _stack.last.id;

  String get _currentFolderName =>
      _stack.isEmpty ? 'Notes' : _stack.last.name;

  List<LibraryFolder> get _children {
    final children = widget.folders
        .where(
          (folder) =>
              folder.parentId == _currentFolderId &&
              folder.id != widget.excludeFolderId,
        )
        .toList();

    children.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return children;
  }

  @override
  Widget build(BuildContext context) {
    final children = _children;
    final palette = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Select destination'),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.86,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (_stack.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                    onPressed: () => setState(() => _stack.removeLast()),
                  )
                else
                  const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentFolderName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Divider(),

            Expanded(
              child: children.isEmpty
                  ? Center(
                      child: Text(
                        'No subfolders here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: palette.outline,
                            ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        final folder = children[index];

                        return ListTile(
                          leading: const Icon(Icons.folder),
                          title: Text(
                            folder.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            setState(() => _stack.add(folder));
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, _currentFolderId);
          },
          child: const Text('Move Here'),
        ),
      ],
    );
  }
}
