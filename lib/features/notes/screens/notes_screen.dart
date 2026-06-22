import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../data/library_repository.dart';
import '../domain/library_folder.dart';
import '../domain/note_category.dart';
import '../domain/note_item.dart';
import '../providers/library_provider.dart';

enum _LibrarySection {
  browse,
  favorites,
  archived,
  trash,
}

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final List<LibraryFolder> _folderStack = [];
  _LibrarySection _section = _LibrarySection.browse;

  String get _folderId =>
      _folderStack.isEmpty ? LibraryFolder.rootId : _folderStack.last.id;

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(libraryActionControllerProvider);
    final folders = switch (_section) {
      _LibrarySection.browse => ref.watch(childFoldersProvider(_folderId)),
      _LibrarySection.favorites => ref.watch(favoriteFoldersProvider),
      _LibrarySection.archived => ref.watch(archivedFoldersProvider),
      _LibrarySection.trash => ref.watch(deletedFoldersProvider),
    };
    final notes = switch (_section) {
      _LibrarySection.browse =>
          ref.watch(notesInFolderProvider(_folderId)),

      _LibrarySection.trash =>
          ref.watch(deletedNotesProvider),

      _ =>
      const AsyncValue<List<NoteItem>>.data([]),
    };

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              sliver: SliverToBoxAdapter(
                child: _LibraryHeader(
                  section: _section,
                  folderStack: _folderStack,
                  isBusy: actionState.isLoading,
                  onSectionChanged: _changeSection,
                  onBreadcrumbPressed: _openBreadcrumb,
                  onCreateFolder: _createFolder,
                  onCreateNote: _createNote,
                  onUpload: _uploadNotes,
                ),
              ),
            ),
            ..._buildFolderSlivers(folders),
            if (_section == _LibrarySection.browse) ..._buildNoteSlivers(
              notes,
              folders.hasValue
                  ? folders.valueOrNull?.isNotEmpty ?? false
                  : false,
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
        if (actionState.isLoading)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  List<Widget> _buildFolderSlivers(
      AsyncValue<List<LibraryFolder>> folders,
      ){
    return folders.when(
      loading: () => const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (error, _) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _ErrorState(message: _friendlyError(error)),
        ),
      ],
      data: (items) => [
        if (items.isNotEmpty)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Folders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisExtent: 92,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final folder = items[index];
              return _FolderCard(
                folder: folder,
                isArchivedSection: _section == _LibrarySection.archived,
                isTrashSection: _section == _LibrarySection.trash,
                onOpen: () => _openFolder(folder),
                onDelete: () => _moveFolderToTrash(folder),
                onRestore: () => _restoreFolder(folder),
                onPermanentDelete: () => _permanentlyDeleteFolder(folder),
                onToggleFavorite: () => _toggleFavorite(folder),
                onToggleArchived: () => _toggleArchived(folder),
              );
            },
          ),
        ),
        if (items.isEmpty && _section != _LibrarySection.browse)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: switch (_section) {
                _LibrarySection.favorites => Icons.star_outline,
                _LibrarySection.archived => Icons.archive_outlined,
                _LibrarySection.trash => Icons.delete_outline,
                _ => Icons.folder_outlined,
              },
              title: switch (_section) {
                _LibrarySection.favorites => 'No favourite folders',
                _LibrarySection.archived => 'No archived folders',
                _LibrarySection.trash => 'Trash is empty',
                _ => '',
              },
              message: switch (_section) {
                _LibrarySection.favorites =>
                'Mark useful folders as favourites for quick access.',

                _LibrarySection.archived =>
                'Folders you archive will appear here.',

                _LibrarySection.trash =>
                'Deleted folders and notes will appear here.',

                _ => '',
              },
            ),
          ),
      ],
    );
  }

  List<Widget> _buildNoteSlivers(
      AsyncValue<List<NoteItem>> notes,
      bool hasFolders,
      ){
    return notes.when(
      loading: () => const [
        SliverPadding(
          padding: EdgeInsets.all(24),
          sliver: SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
      error: (error, _) => [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: _ErrorState(message: _friendlyError(error)),
          ),
        ),
      ],
      data: (items) => [
        if (items.isNotEmpty)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Files',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, index) => _NoteCard(note: items[index]),
          ),
        ),
        if (items.isEmpty && !hasFolders)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 48, 20, 24),
            sliver: SliverToBoxAdapter(
              child: _EmptyState(
                icon: Icons.upload_file_outlined,
                title: 'This folder is empty',
                message: 'Create a subfolder or upload your first note.',
              ),
            ),
          ),
      ],
    );
  }

  void _changeSection(_LibrarySection section) {
    setState(() {
      _section = section;
      _folderStack.clear();
    });
  }

  void _openFolder(LibraryFolder folder) {
    if (_section == _LibrarySection.archived) return;

    setState(() {
      _section = _LibrarySection.browse;
      if (_folderStack.isEmpty || _folderStack.last.id != folder.id) {
        _folderStack.add(folder);
      }
    });
  }

  void _openBreadcrumb(int index) {
    setState(() {
      if (index < 0) {
        _folderStack.clear();
      } else {
        _folderStack.removeRange(index + 1, _folderStack.length);
      }
    });
  }

  Future<void> _createFolder() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _CreateFolderDialog(),
    );
    if (!mounted || name == null) return;

    final created = await ref
        .read(libraryActionControllerProvider.notifier)
        .createFolder(parentId: _folderId, name: name);
    if (!mounted) return;

    _showResult(created, successMessage: 'Folder created.');
  }

  Future<void> _createNote() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New note'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Note name',
              hintText: 'OSI Revision Notes',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(dialogContext, value);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (!mounted || name == null) return;

    final created = await ref
        .read(libraryActionControllerProvider.notifier)
        .createInternalNote(
      folderId: _folderId,
      name: name,
    );

    if (!mounted) return;

    _showResult(
      created,
      successMessage: 'Note created.',
    );
  }

  Future<void> _moveFolderToTrash(LibraryFolder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Move folder to Trash?'),
        content: const Text(
          'This folder, all nested folders, and all notes inside them '
              'will be moved to Trash.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Move'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(libraryActionControllerProvider.notifier)
        .softDeleteFolder(folder);

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Folder moved to Trash.',
    );
  }

  Future<void> _restoreFolder(LibraryFolder folder) async {
    final success = await ref
        .read(libraryActionControllerProvider.notifier)
        .restoreFolder(folder);

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Folder restored.',
    );
  }

  Future<void> _permanentlyDeleteFolder(
      LibraryFolder folder,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: const Text(
          'This folder, all child folders, and all notes inside it '
              'will be permanently deleted.\n\n'
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(libraryActionControllerProvider.notifier)
        .permanentlyDeleteFolder(folder);

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Folder permanently deleted.',
    );
  }

  Future<void> _uploadNotes() async {
    final category = await showDialog<NoteCategory>(
      context: context,
      builder: (context) => const _CategoryDialog(),
    );
    if (!mounted || category == null) return;

    final files = await openFiles(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Documents',
          extensions: [
            'pdf',
            'doc',
            'docx',
            'ppt',
            'pptx',
            'txt',
          ],
        ),
      ],
    );

    if (!mounted || files.isEmpty) return;

    var uploaded = 0;

    for (final file in files) {
      final bytes = await file.readAsBytes();

      if (bytes.length >= LibraryRepository.maxUploadBytes) {
        _showMessage('${file.name} is larger than 10 MB.');
        continue;
      }

      final extension =
      file.name.contains('.')
          ? file.name.split('.').last
          : '';

      final success =
      await ref.read(libraryActionControllerProvider.notifier).uploadNote(
        folderId: _folderId,
        fileName: file.name,
        extension: extension,
        bytes: bytes,
        category: category,
      );

      if (!mounted) return;

      if (success) {
        uploaded++;
      } else {
        _showActionError();
      }
    }

    if (uploaded > 0 && mounted) {
      _showMessage(
        '$uploaded file${uploaded == 1 ? '' : 's'} uploaded.',
      );
    }
  }

  Future<void> _toggleFavorite(LibraryFolder folder) async {
    final success = await ref
        .read(libraryActionControllerProvider.notifier)
        .setFolderFavorite(folder, !folder.isFavorite);
    if (!mounted) return;
    _showResult(
      success,
      successMessage: folder.isFavorite
          ? 'Removed from favourites.'
          : 'Added to favourites.',
    );
  }

  Future<void> _toggleArchived(LibraryFolder folder) async {
    final success = await ref
        .read(libraryActionControllerProvider.notifier)
        .setFolderArchived(folder, !folder.isArchived);
    if (!mounted) return;
    _showResult(
      success,
      successMessage:
          folder.isArchived ? 'Folder restored.' : 'Folder archived.',
    );
  }

  void _showResult(bool success, {required String successMessage}) {
    if (success) {
      _showMessage(successMessage);
    } else {
      _showActionError();
    }
  }

  void _showActionError() {
    final error = ref.read(libraryActionControllerProvider).error;
    _showMessage(_friendlyError(error));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static String _friendlyError(Object? error) {
    if (error is ArgumentError) return error.message.toString();
    return 'Something went wrong. Please try again.';
  }
}

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({
    required this.section,
    required this.folderStack,
    required this.isBusy,
    required this.onSectionChanged,
    required this.onBreadcrumbPressed,
    required this.onCreateFolder,
    required this.onCreateNote,
    required this.onUpload,
  });

  final _LibrarySection section;
  final List<LibraryFolder> folderStack;
  final bool isBusy;
  final ValueChanged<_LibrarySection> onSectionChanged;
  final ValueChanged<int> onBreadcrumbPressed;
  final VoidCallback onCreateFolder;
  final VoidCallback onCreateNote;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes', style: Theme.of(context).textTheme.headlineMedium),
        const Gap(4),
        Text(
          'Organise study material into folders and categories.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const Gap(20),
        SegmentedButton<_LibrarySection>(
          segments: const [
            ButtonSegment(
              value: _LibrarySection.browse,
              icon: Icon(Icons.folder_outlined),
              label: Text('Library'),
            ),
            ButtonSegment(
              value: _LibrarySection.favorites,
              icon: Icon(Icons.star_outline),
              label: Text('Favourites'),
            ),
            ButtonSegment(
              value: _LibrarySection.archived,
              icon: Icon(Icons.archive_outlined),
              label: Text('Archived'),
            ),
            ButtonSegment(
              value: _LibrarySection.trash,
              icon: Icon(Icons.delete_outline),
              label: Text('Trash'),
            ),
          ],
          selected: {section},
          onSelectionChanged:
              isBusy ? null : (selection) => onSectionChanged(selection.first),
        ),
        if (section == _LibrarySection.browse) ...[
          const Gap(18),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            children: [
              TextButton.icon(
                onPressed: () => onBreadcrumbPressed(-1),
                icon: const Icon(Icons.home_outlined, size: 18),
                label: const Text('Notes'),
              ),
              for (var index = 0; index < folderStack.length; index++) ...[
                const Icon(Icons.chevron_right, size: 18),
                TextButton(
                  onPressed: () => onBreadcrumbPressed(index),
                  child: Text(folderStack[index].name),
                ),
              ],
            ],
          ),
          const Gap(10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: isBusy ? null : onCreateFolder,
                icon: const Icon(Icons.create_new_folder_outlined),
                label: const Text('New folder'),
              ),
              FilledButton.icon(
                onPressed: isBusy ? null : onUpload,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Upload files'),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: isBusy ? null : onCreateNote,
                icon: const Icon(Icons.note_add_outlined),
                label: const Text('New note'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({
    required this.folder,
    required this.isArchivedSection,
    required this.isTrashSection,
    required this.onOpen,
    required this.onToggleFavorite,
    required this.onToggleArchived,
    required this.onDelete,
    required this.onRestore,
    required this.onPermanentDelete,
  });

  final LibraryFolder folder;
  final bool isTrashSection;
  final bool isArchivedSection;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onRestore;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleArchived;
  final VoidCallback onPermanentDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isArchivedSection || isTrashSection ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Row(
            children: [
              Icon(
                isArchivedSection ? Icons.folder_off_outlined : Icons.folder,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  folder.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (folder.isFavorite)
                Icon(
                  Icons.star,
                  size: 18,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              PopupMenuButton<_FolderAction>(
                onSelected: (action) {
                  switch (action) {
                    case _FolderAction.favorite:
                      onToggleFavorite();

                    case _FolderAction.archive:
                      onToggleArchived();

                    case _FolderAction.trash:
                      onDelete();

                    case _FolderAction.restore:
                      onRestore();

                    case _FolderAction.permanentDelete:
                      onPermanentDelete();
                  }
                },
                itemBuilder: (context) {
                  if (isTrashSection) {
                    return [
                      const PopupMenuItem(
                        value: _FolderAction.restore,
                        child: Text('Restore'),
                      ),
                      const PopupMenuItem(
                        value: _FolderAction.permanentDelete,
                        child: Text('Delete Permanently'),
                      ),
                    ];
                  }

                  return [
                    if (!isArchivedSection)
                      PopupMenuItem(
                        value: _FolderAction.favorite,
                        child: Text(
                          folder.isFavorite
                              ? 'Remove favourite'
                              : 'Add to favourites',
                        ),
                      ),

                    PopupMenuItem(
                      value: _FolderAction.archive,
                      child: Text(
                        isArchivedSection
                            ? 'Restore'
                            : 'Archive',
                      ),
                    ),

                    const PopupMenuItem(
                      value: _FolderAction.trash,
                      child: Text('Move to Trash'),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _FolderAction {
  favorite,
  archive,
  trash,
  restore,
  permanentDelete,
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final NoteItem note;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_fileIcon(note.extension)),
        ),
        title: Text(note.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${note.category.label} • ${_formatBytes(note.sizeBytes)}',
        ),
        trailing: note.source == 'classroom'
            ? const Tooltip(
                message: 'Imported from Google Classroom',
                child: Icon(Icons.school_outlined),
              )
            : null,
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

class _CreateFolderDialog extends StatefulWidget {
  const _CreateFolderDialog();

  @override
  State<_CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<_CreateFolderDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New folder'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 80,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Folder name',
          hintText: 'Semester 1',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }
}

class _CategoryDialog extends StatelessWidget {
  const _CategoryDialog();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Choose note category'),
      children: [
        for (final category in NoteCategory.values)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, category),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(category.label),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const Gap(12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Gap(4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      icon: Icons.error_outline,
      title: 'Could not load notes',
      message: message,
    );
  }
}
