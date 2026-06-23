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
  String selectedFolderId =
      LibraryFolder.rootId;

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
        width: 400,
        height: 450,
        child: ListView(
          children: [
            RadioListTile<String>(
              value: LibraryFolder.rootId,
              groupValue: selectedFolderId,
              title: const Text('Notes'),
              onChanged: (value) {
                setState(() {
                  selectedFolderId = value!;
                });
              },
            ),
            ...rootFolders.map(
                  (folder) => _FolderTile(
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

class _FolderTile extends StatelessWidget {
  const _FolderTile({
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
  Widget build(BuildContext context) {
    if (folder.id == excludeFolderId) {
      return const SizedBox.shrink();
    }

    final children = folders
        .where(
          (candidate) =>
      candidate.parentId ==
          folder.id,
    )
        .toList();

    return Column(
      children: [
        RadioListTile<String>(
          contentPadding:
          EdgeInsets.only(
            left: 16.0 * depth,
          ),
          value: folder.id,
          groupValue: selectedFolderId,
          title: Text(folder.name),
          onChanged: (value) {
            onSelected(value!);
          },
        ),
        ...children.map(
              (child) => _FolderTile(
            folder: child,
            folders: folders,
            selectedFolderId:
            selectedFolderId,
            excludeFolderId:
            excludeFolderId,
            depth: depth + 1,
            onSelected: onSelected,
          ),
        ),
      ],
    );
  }
}