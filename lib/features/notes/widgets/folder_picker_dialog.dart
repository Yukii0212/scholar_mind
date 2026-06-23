import 'package:flutter/material.dart';

import '../domain/library_folder.dart';

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
  String selectedFolderId = LibraryFolder.rootId;

  @override
  Widget build(BuildContext context) {
    final rootFolders = widget.folders
        .where(
          (folder) =>
      folder.parentId ==
          LibraryFolder.rootId,
    )
        .toList();

    return AlertDialog(
      title: const Text('Select destination'),
      content: SizedBox(
        width: 500,
        height: 500,
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedFolderId ==
                      LibraryFolder.rootId
                      ? Theme.of(context)
                      .colorScheme
                      .primary
                      : Theme.of(context)
                      .dividerColor,
                ),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.folder_open,
                ),
                title: const Text('Notes'),
                trailing:
                selectedFolderId ==
                    LibraryFolder.rootId
                    ? const Icon(
                  Icons.check,
                )
                    : null,
                selected:
                selectedFolderId ==
                    LibraryFolder.rootId,
                onTap: () {
                  setState(() {
                    selectedFolderId =
                        LibraryFolder.rootId;
                  });
                },
              ),
            ),

            const Divider(),

            ...rootFolders.map(
                  (folder) => _FolderTreeTile(
                folder: folder,
                folders: widget.folders,
                selectedFolderId:
                selectedFolderId,
                excludeFolderId:
                widget.excludeFolderId,
                onSelected: (id) {
                  setState(() {
                    selectedFolderId = id;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              selectedFolderId,
            );
          },
          child: const Text('Move Here'),
        ),
      ],
    );
  }
}

class _FolderTreeTile
    extends StatefulWidget {
  const _FolderTreeTile({
    required this.folder,
    required this.folders,
    required this.selectedFolderId,
    required this.onSelected,
    this.excludeFolderId,
    this.depth = 0,
  });

  final LibraryFolder folder;
  final List<LibraryFolder> folders;
  final String selectedFolderId;
  final String? excludeFolderId;
  final int depth;
  final ValueChanged<String> onSelected;

  @override
  State<_FolderTreeTile> createState() =>
      _FolderTreeTileState();
}

class _FolderTreeTileState
    extends State<_FolderTreeTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.folder.id ==
        widget.excludeFolderId) {
      return const SizedBox.shrink();
    }

    final children = widget.folders
        .where(
          (folder) =>
      folder.parentId ==
          widget.folder.id,
    )
        .toList();

    final hasChildren =
        children.isNotEmpty;

    final selected =
        widget.selectedFolderId ==
            widget.folder.id;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius:
          BorderRadius.circular(8),
          onTap: () {
            widget.onSelected(
              widget.folder.id,
            );
          },
          child: Container(
            margin:
            const EdgeInsets.symmetric(
              vertical: 2,
            ),
            padding:
            EdgeInsets.only(
              left:
              20.0 +
                  (widget.depth * 24),
              right: 12,
              top: 6,
              bottom: 6,
            ),
            decoration:
            BoxDecoration(
              color: selected
                  ? Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  : null,
              borderRadius:
              BorderRadius.circular(
                8,
              ),
            ),
            child: Row(
              children: [
                if (hasChildren)
                  IconButton(
                    splashRadius: 20,
                    icon: Icon(
                      _expanded
                          ? Icons.expand_more
                          : Icons.chevron_right,
                    ),
                    onPressed: () {
                      setState(() {
                        _expanded =
                        !_expanded;
                      });
                    },
                  )
                else
                  const SizedBox(
                    width: 48,
                  ),

                Icon(
                  Icons.folder,
                  color: selected
                      ? Theme.of(context)
                      .colorScheme
                      .primary
                      : null,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    widget.folder.name,
                  ),
                ),

                if (selected)
                  const Icon(
                    Icons.check,
                  ),
              ],
            ),
          ),
        ),

        if (_expanded)
          ...children.map(
                (child) =>
                _FolderTreeTile(
                  folder: child,
                  folders:
                  widget.folders,
                  selectedFolderId:
                  widget
                      .selectedFolderId,
                  excludeFolderId:
                  widget
                      .excludeFolderId,
                  depth:
                  widget.depth + 1,
                  onSelected:
                  widget.onSelected,
                ),
          ),
      ],
    );
  }
}