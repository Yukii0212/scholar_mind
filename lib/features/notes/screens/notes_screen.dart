import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gap/gap.dart';

import '../../../core/app_tasks/domain/app_task_type.dart';
import '../../../core/app_tasks/services/app_task_controller.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/repository/library_repository.dart';

import '../domain/library_folder.dart';
import '../domain/note_category.dart';
import '../domain/note_item.dart';
import '../domain/library_enums.dart';

import '../providers/library_provider.dart';
import '../services/file_cache_service.dart';

import '../widgets/library_header.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/folder_card.dart';
import '../widgets/note_card.dart';
import '../widgets/folder_picker_dialog.dart';
import '../widgets/category_dialog.dart';
import '../widgets/folder_dialogs.dart';
import '../widgets/trash_section.dart';

import '../services/file_open_service.dart';

import 'google_classroom_import_screen.dart';
import 'google_drive_import_screen.dart';
import 'note_editor_screen.dart';

enum _ImportSource {
  device,
  classroom,
  drive,
}

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final List<LibraryFolder> _folderStack = [];
  LibrarySection _section = LibrarySection.browse;

  String get _folderId =>
      _folderStack.isEmpty ? LibraryFolder.rootId : _folderStack.last.id;

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(
      libraryActionControllerProvider,
    );
    final folders = switch (_section) {
      LibrarySection.browse => ref.watch(childFoldersProvider(_folderId)),
      LibrarySection.favorites => ref.watch(favoriteFoldersProvider),
      LibrarySection.archived => ref.watch(archivedFoldersProvider),
      LibrarySection.trash => ref.watch(deletedFoldersProvider),
    };
    final notes = switch (_section) {
      LibrarySection.browse => ref.watch(notesInFolderProvider(_folderId)),
      LibrarySection.favorites => ref.watch(favoriteNotesProvider),
      LibrarySection.trash => ref.watch(deletedNotesProvider),
      _ => const AsyncValue<List<NoteItem>>.data([]),
    };

    return Scaffold(
      floatingActionButton: _section == LibrarySection.browse
          ? SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close,
              spacing: 12,
              children: [
                SpeedDialChild(
                  child: const Icon(
                    Icons.file_upload_outlined,
                  ),
                  label: 'Import File',
                  onTap: _uploadNotes,
                ),
                SpeedDialChild(
                  child: const Icon(
                    Icons.note_add_outlined,
                  ),
                  label: 'New Note',
                  onTap: _createNote,
                ),
                SpeedDialChild(
                  child: const Icon(
                    Icons.create_new_folder,
                  ),
                  label: 'New Folder',
                  onTap: _createFolder,
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: LibraryHeader(
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
              if (_section == LibrarySection.trash)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    12,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: TrashSection(
                      onRestoreAll: _restoreAll,
                      onDeleteAll: _permanentlyDeleteAll,
                      folders: folders.valueOrNull?.map((folder) {
                            return FolderCard(
                              folder: folder,
                              isTrashSection: true,
                              isArchivedSection: false,
                              onOpen: () => _openFolder(folder),
                              onDelete: () => _moveFolderToTrash(folder),
                              onMove: () => _moveFolder(folder),
                              onRestore: () => _restoreFolder(folder),
                              onRename: () => _renameFolder(folder),
                              onPermanentDelete: () =>
                                  _permanentlyDeleteFolder(folder),
                              onToggleFavorite: () => _toggleFavorite(folder),
                              onToggleArchived: () => _toggleArchived(folder),
                            );
                          }).toList() ??
                          const [],
                      files: notes.valueOrNull?.map((note) {
                            return NoteCard(
                              note: note,
                              onTap: () => _openNote(note),
                              onRename: () => _renameNote(note),
                              onMove: () => _moveNote(note),
                              onCopy: () => _copyNote(note),
                              onToggleFavorite: () => _toggleNoteFavorite(note),
                              onDelete: () => _deleteNote(note),
                              isTrashSection: true,
                              onRestore: () => _restoreNote(note),
                              onPermanentDelete: () =>
                                  _permanentlyDeleteNote(note),
                              onOpenWith: () => _openNoteWith(note),
                            );
                          }).toList() ??
                          const [],
                    ),
                  ),
                ),
              ..._buildFolderSlivers(
                folders,
                notes.hasValue ? notes.valueOrNull?.isNotEmpty ?? false : false,
              ),
              if (_section == LibrarySection.browse ||
                  _section == LibrarySection.favorites ||
                  _section == LibrarySection.trash)
                ..._buildNoteSlivers(
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
      ),
    );
  }

  Future<void> _restoreAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore everything?'),
        content: const Text(
          'All folders and notes currently in the Trash will be restored.\n\n'
          'Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Restore All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(
          libraryActionControllerProvider.notifier,
        )
        .restoreAll();

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'All items restored.',
    );
  }

  Future<void> _permanentlyDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete everything?'),
        content: const Text(
          'Everything in the Trash will be permanently deleted.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final userId = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (userId == null) return;

    final repository = ref.read(libraryRepositoryProvider);
    final taskController = ref.read(appTaskControllerProvider);

    unawaited(
      taskController.run<void>(
        id: 'notes_bulk_delete',
        type: AppTaskType.bulkDelete,
        title: 'Emptying Notes trash',
        task: (progress) => repository.permanentlyDeleteAll(
          userId: userId,
        ),
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emptying trash in the background.'),
      ),
    );
  }

  List<Widget> _buildFolderSlivers(
    AsyncValue<List<LibraryFolder>> folders,
    bool hasNotes,
  ) {
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
          child: ErrorState(message: _friendlyError(error)),
        ),
      ],
      data: (items) {
        if (_section == LibrarySection.trash) {
          return const <Widget>[];
        }

        return [
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
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Gap(8),
              itemBuilder: (context, index) {
                final folder = items[index];

                return FolderCard(
                  folder: folder,
                  isArchivedSection: _section == LibrarySection.archived,
                  isTrashSection: _section == LibrarySection.trash,
                  onOpen: () => _openFolder(folder),
                  onDelete: () => _moveFolderToTrash(folder),
                  onMove: () => _moveFolder(folder),
                  onRestore: () => _restoreFolder(folder),
                  onRename: () => _renameFolder(folder),
                  onPermanentDelete: () => _permanentlyDeleteFolder(folder),
                  onToggleFavorite: () => _toggleFavorite(folder),
                  onToggleArchived: () => _toggleArchived(folder),
                );
              },
            ),
          ),
          if (items.isEmpty && !hasNotes && _section != LibrarySection.browse)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: switch (_section) {
                  LibrarySection.favorites => Icons.star_outline,
                  LibrarySection.archived => Icons.archive_outlined,
                  LibrarySection.trash => Icons.delete_outline,
                  _ => Icons.folder_outlined,
                },
                title: switch (_section) {
                  LibrarySection.favorites => 'No favourite folders',
                  LibrarySection.archived => 'No archived folders',
                  LibrarySection.trash => 'Trash is empty',
                  _ => '',
                },
                message: switch (_section) {
                  LibrarySection.favorites =>
                    'Mark useful folders as favourites for quick access.',
                  LibrarySection.archived =>
                    'Folders you archive will appear here.',
                  LibrarySection.trash =>
                    'Deleted folders and notes will appear here.',
                  _ => '',
                },
              ),
            ),
        ];
      },
    );
  }

  List<Widget> _buildNoteSlivers(
    AsyncValue<List<NoteItem>> notes,
    bool hasFolders,
  ) {
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
            child: ErrorState(message: _friendlyError(error)),
          ),
        ),
      ],
      data: (items) {
        if (_section == LibrarySection.trash) {
          return const <Widget>[];
        }

        return [
          if (items.isNotEmpty)
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                8,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Files',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Gap(8),
              itemBuilder: (context, index) => NoteCard(
                note: items[index],
                onTap: () => _openNote(items[index]),
                onRename: () => _renameNote(items[index]),
                onMove: () => _moveNote(items[index]),
                onCopy: () => _copyNote(items[index]),
                onToggleFavorite: () => _toggleNoteFavorite(items[index]),
                onDelete: () => _deleteNote(items[index]),
                isTrashSection: _section == LibrarySection.trash,
                onRestore: () => _restoreNote(items[index]),
                onPermanentDelete: () => _permanentlyDeleteNote(items[index]),
                onOpenWith: () => _openNoteWith(items[index]),
              ),
            ),
          ),
          if (items.isEmpty && !hasFolders && _section != LibrarySection.trash)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                48,
                20,
                24,
              ),
              sliver: SliverToBoxAdapter(
                child: EmptyState(
                  icon: _section == LibrarySection.trash
                      ? Icons.delete_outline
                      : Icons.upload_file_outlined,
                  title: _section == LibrarySection.trash
                      ? 'Trash is empty'
                      : 'This folder is empty',
                  message: _section == LibrarySection.trash
                      ? 'Deleted notes will appear here.'
                      : 'Create a subfolder or upload your first note.',
                ),
              ),
            ),
        ];
      },
    );
  }

  void _changeSection(LibrarySection section) {
    setState(() {
      _section = section;
      _folderStack.clear();
    });
  }

  void _openFolder(LibraryFolder folder) {
    if (_section == LibrarySection.archived) return;

    setState(() {
      _section = LibrarySection.browse;
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
      builder: (context) => const CreateFolderDialog(),
    );
    if (!mounted || name == null) return;

    final created = await ref
        .read(libraryActionControllerProvider.notifier)
        .createFolder(parentId: _folderId, name: name);
    if (!mounted) return;

    _showResult(created, successMessage: 'Folder created.');
  }

  Future<String?> _pickFolder({
    String? excludeFolderId,
  }) async {
    final folders = await ref.read(
      allFoldersProvider.future,
    );

    if (!mounted) return null;

    return showDialog<String>(
      context: context,
      builder: (_) => FolderPickerDialog(
        folders: folders,
        excludeFolderId: excludeFolderId,
      ),
    );
  }

  Future<void> _moveNote(
    NoteItem note,
  ) async {
    final destination = await _pickFolder();

    if (destination == null) return;

    final success = await ref
        .read(
          libraryActionControllerProvider.notifier,
        )
        .moveNote(
          noteId: note.id,
          destinationFolderId: destination,
        );

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Note moved successfully.',
    );
  }

  Future<void> _copyNote(
    NoteItem note,
  ) async {
    final destination = await _pickFolder();

    if (destination == null) {
      return;
    }

    final success = await ref
        .read(
          libraryActionControllerProvider.notifier,
        )
        .copyNote(
          noteId: note.id,
          destinationFolderId: destination,
        );

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Note copied successfully.',
    );
  }

  Future<void> _moveFolder(
    LibraryFolder folder,
  ) async {
    final destination = await _pickFolder(
      excludeFolderId: folder.id,
    );

    if (destination == null) return;

    final success = await ref
        .read(
          libraryActionControllerProvider.notifier,
        )
        .moveFolder(
          folderId: folder.id,
          destinationFolderId: destination,
        );

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Folder moved successfully.',
    );
  }

  Future<void> _renameFolder(
    LibraryFolder folder,
  ) async {
    final controller = TextEditingController(
      text: folder.name,
    );

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rename folder'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Folder name',
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
                  Navigator.pop(
                    dialogContext,
                    value,
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted || name == null) return;

    final success = await ref
        .read(
          libraryActionControllerProvider.notifier,
        )
        .renameFolder(
          folderId: folder.id,
          name: name,
        );

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Folder renamed successfully.',
    );
  }

  Future<void> _renameNote(
    NoteItem note,
  ) async {
    // Uploaded files keep a locked extension so renaming can't produce a
    // file the OS/other apps no longer recognise — only the base name is
    // editable. Internal notes have no extension and are unaffected.
    final hasLockedExtension =
        !note.isInternal && note.extension.isNotEmpty;

    final extensionSuffix = '.${note.extension}';

    final baseName = hasLockedExtension &&
            note.name.toLowerCase().endsWith(
                  extensionSuffix.toLowerCase(),
                )
        ? note.name.substring(
            0,
            note.name.length - extensionSuffix.length,
          )
        : note.name;

    final controller = TextEditingController(
      text: baseName,
    );

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rename note'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Note name',
              suffixText:
                  hasLockedExtension ? extensionSuffix : null,
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
                  Navigator.pop(
                    dialogContext,
                    hasLockedExtension
                        ? '$value$extensionSuffix'
                        : value,
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted || name == null) return;

    final success = await ref
        .read(
          libraryActionControllerProvider.notifier,
        )
        .renameNote(
          noteId: note.id,
          name: name,
        );

    if (!mounted) return;

    if (success && note.storagePath.isNotEmpty) {
      await FileCacheService.renameCachedFile(
        storagePath: note.storagePath,
        oldFileName: note.name,
        newFileName: name,
      );
    }

    _showResult(
      success,
      successMessage: 'Note renamed successfully.',
    );
  }

  Future<void> _toggleNoteFavorite(
    NoteItem note,
  ) async {
    final success = await ref
        .read(
          libraryActionControllerProvider.notifier,
        )
        .toggleNoteFavorite(note);

    if (!mounted) return;

    _showResult(
      success,
      successMessage:
          note.isFavorite ? 'Removed from favourites.' : 'Added to favourites.',
    );
  }

  Future<void> _deleteNote(
    NoteItem note,
  ) async {
    final success = await ref
        .read(
          libraryActionControllerProvider.notifier,
        )
        .softDeleteNote(note);

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Moved to Trash.',
    );
  }

  Future<void> _restoreNote(
    NoteItem note,
  ) async {
    final success = await ref
        .read(
          libraryActionControllerProvider.notifier,
        )
        .restoreNote(note);

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Note restored.',
    );
  }

  Future<void> _permanentlyDeleteNote(
    NoteItem note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: const Text(
          'This note will be permanently deleted.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              false,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              true,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(
          libraryActionControllerProvider.notifier,
        )
        .permanentlyDeleteNote(note);

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Note permanently deleted.',
    );
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
              hintText: 'Start writing your notes...',
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

  Future<void> _openNoteWith(NoteItem note) async {
    if (note.isInternal) return;

    await FileOpenService.openExternally(note);
  }

  Future<void> _openNote(NoteItem note) async {
    if (_section == LibrarySection.trash) {
      return;
    }

    if (!note.isInternal) {
      await FileOpenService.openUploadedFile(context, note);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          noteId: note.id,
          noteTitle: note.name,
          content: note.content,
        ),
      ),
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
    final source = await showModalBottomSheet<_ImportSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.phone_android,
                ),
                title: const Text(
                  'Device',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                    _ImportSource.device,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.school,
                ),
                title: const Text(
                  'Google Classroom',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                    _ImportSource.classroom,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.cloud,
                ),
                title: const Text(
                  'Google Drive',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                    _ImportSource.drive,
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || source == null) {
      return;
    }

    switch (source) {
      case _ImportSource.device:
        await _uploadFromDevice();
        break;

      case _ImportSource.classroom:
        await _importFromClassroom();
        break;

      case _ImportSource.drive:
        await _importFromDrive();
        break;
    }
  }

  Future<void> _importFromClassroom() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GoogleClassroomImportScreen(
          defaultFolderId: _folderId,
        ),
      ),
    );
  }

  Future<void> _importFromDrive() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GoogleDriveImportScreen(
          defaultFolderId: _folderId,
        ),
      ),
    );
  }

  Future<void> _uploadFromDevice() async {
    final category = await showDialog<NoteCategory>(
      context: context,
      builder: (context) => const CategoryDialog(),
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
            'md',
            'jpg',
            'jpeg',
            'png',
            'webp',
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
          file.name.contains('.') ? file.name.split('.').last : '';

      final storagePath =
          await ref.read(libraryActionControllerProvider.notifier).uploadNote(
                folderId: _folderId,
                fileName: file.name,
                extension: extension,
                bytes: bytes,
                category: category,
              );

      if (!mounted) return;

      if (storagePath != null) {
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
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  static String _friendlyError(Object? error) {
    if (error is ArgumentError) return error.message.toString();
    return 'Something went wrong. Please try again.';
  }
}
