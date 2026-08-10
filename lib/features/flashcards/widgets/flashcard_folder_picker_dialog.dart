import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../domain/flashcard_folder.dart';
import '../providers/flashcard_provider.dart';
import 'flashcard_folder_dialogs.dart';

/// Picks a destination folder by drilling down one level at a time,
/// matching QuizFolderPickerDialog. Also lets the user create a new
/// folder inline, right from wherever they're currently browsing, instead
/// of forcing them to cancel out, create the folder elsewhere, then come
/// back and select it.
class FlashcardFolderPickerDialog extends ConsumerStatefulWidget {
  const FlashcardFolderPickerDialog({
    super.key,
    required this.folders,
    this.excludeFolderId,
  });

  final List<FlashcardFolder> folders;
  final String? excludeFolderId;

  @override
  ConsumerState<FlashcardFolderPickerDialog> createState() =>
      _FlashcardFolderPickerDialogState();
}

class _FlashcardFolderPickerDialogState
    extends ConsumerState<FlashcardFolderPickerDialog> {
  late List<FlashcardFolder> _folders;
  final List<FlashcardFolder> _stack = [];
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _folders = widget.folders;
  }

  String get _currentFolderId =>
      _stack.isEmpty ? FlashcardFolder.rootId : _stack.last.id;

  String get _currentFolderName =>
      _stack.isEmpty ? 'My Flashcards' : _stack.last.name;

  List<FlashcardFolder> get _children {
    final children = _folders
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

  Future<void> _createFolder() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CreateFlashcardFolderDialog(),
    );

    if (name == null) return;

    final userId = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (userId == null) return;

    setState(() => _creating = true);

    try {
      final newFolderId = await ref.read(flashcardRepositoryProvider).createFolder(
            userId: userId,
            parentId: _currentFolderId,
            name: name,
          );

      final refreshed =
          await ref.refresh(flashcardAllFoldersProvider.future);

      if (!mounted) return;

      final newFolder = refreshed.firstWhere(
        (folder) => folder.id == newFolderId,
        orElse: () => FlashcardFolder(
          id: newFolderId,
          name: name,
          parentId: _currentFolderId,
          isDeleted: false,
          deletedAt: null,
          deletedAsCascade: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      setState(() {
        _folders = refreshed;
        _stack.add(newFolder);
      });
    } finally {
      if (mounted) setState(() => _creating = false);
    }
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
                IconButton(
                  icon: _creating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.create_new_folder_outlined),
                  tooltip: 'New folder',
                  onPressed: _creating ? null : _createFolder,
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
