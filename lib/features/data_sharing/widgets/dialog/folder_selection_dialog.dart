import 'package:flutter/material.dart';

enum FolderSelectionOption {
  folderOnly,
  chooseResources,
  includeEverything,
}

class FolderSelectionDialog extends StatelessWidget {
  const FolderSelectionDialog({
    super.key,
    required this.folderName,
  });

  final String folderName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.folder_rounded,
      ),
      title: const Text(
        'Include Child Resources?',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'How would you like to export "$folderName"?',
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(
              Icons.folder_outlined,
            ),
            title: const Text(
              'Folder Only',
            ),
            subtitle: const Text(
              'Export only this folder.',
            ),
            onTap: () {
              Navigator.pop(
                context,
                FolderSelectionOption.folderOnly,
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.rule_folder_outlined,
            ),
            title: const Text(
              'Choose Resources',
            ),
            subtitle: const Text(
              'Select which child resources to include.',
            ),
            onTap: () {
              Navigator.pop(
                context,
                FolderSelectionOption.chooseResources,
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.select_all_rounded,
            ),
            title: const Text(
              'Include Everything',
            ),
            subtitle: const Text(
              'Export this folder and all descendants.',
            ),
            onTap: () {
              Navigator.pop(
                context,
                FolderSelectionOption.includeEverything,
              );
            },
          ),
        ],
      ),
    );
  }
}