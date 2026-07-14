import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../data/quiz_library_repository.dart';

import '../domain/quiz_folder.dart';
import '../domain/quiz_attempt.dart';
import '../domain/quiz_enums.dart';

import '../providers/quiz_library_provider.dart';

import '../widgets/quiz_header.dart';
import '../widgets/quiz_error_state.dart';
import '../widgets/quiz_empty_state.dart';
import '../widgets/quiz_folder_card.dart';
import '../widgets/quiz_folder_picker_dialog.dart';
import '../widgets/quiz_folder_dialogs.dart';

import 'generate_quiz_screen.dart';
import 'quiz_viewer_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final List<QuizFolder> _folderStack = [];

  QuizSection _section =
      QuizSection.browse;

  String get _folderId =>
      _folderStack.isEmpty ? QuizFolder.rootId : _folderStack.last.id;

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(
      quizLibraryActionControllerProvider,
    );
    final folders = switch (_section) {
      QuizSection.browse =>
          ref.watch(childFoldersProvider(_folderId)),
      QuizSection.favorites =>
          ref.watch(favoriteFoldersProvider),
      QuizSection.archived =>
          ref.watch(archivedFoldersProvider),
      QuizSection.trash =>
          ref.watch(deletedFoldersProvider),
    };
    final quizzes = switch (_section) {
      QuizSection.browse =>
          ref.watch(quizzesInFolderProvider(_folderId)),

      QuizSection.favorites =>
          ref.watch(favoriteQuizzesProvider),

      QuizSection.trash =>
          ref.watch(deletedQuizzesProvider),

      _ =>
      const AsyncValue<List<QuizAttempt>>.data([]),
    };

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              sliver: SliverToBoxAdapter(
                child: QuizHeader(
                  section: _section,
                  folderStack: _folderStack,
                  isBusy: actionState.isLoading,
                  onSectionChanged: _changeSection,
                  onBreadcrumbPressed: _openBreadcrumb,
                  onCreateFolder: _createFolder,
                  onGenerateQuiz: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GenerateQuizScreen(),
                      ),
                    );
                  },
                  onRestoreAll: _restoreAll,
                  onDeleteAll: _permanentlyDeleteAll,
                ),
              ),
            ),
            ..._buildFolderSlivers(
              folders,
              quizzes.hasValue
                  ? quizzes.valueOrNull?.isNotEmpty ?? false
                  : false,
            ),
            if (_section == QuizSection.browse ||
                _section == QuizSection.favorites ||
                _section == QuizSection.trash) ..._buildQuizSlivers(
              quizzes,
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

  Future<void> _restoreAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore everything?'),
        content: const Text(
          'All folders and quizzes currently in the Trash will be restored.\n\n'
              'Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Restore All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(
      quizLibraryActionControllerProvider.notifier,
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
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(
      quizLibraryActionControllerProvider.notifier,
    )
        .permanentlyDeleteAll();

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Trash emptied.',
    );
  }

  List<Widget> _buildFolderSlivers(
      AsyncValue<List<QuizFolder>> folders,
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
          child: QuizErrorState(message: _friendlyError(error)),
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
              return QuizFolderCard(
                folder: folder,
                isArchivedSection:
                _section == QuizSection.archived,
                isTrashSection:
                _section == QuizSection.trash,
                onOpen: () => _openFolder(folder),
                onDelete: () => _moveFolderToTrash(folder),

                onMove: () => _moveFolder(folder),

                onRestore: () => _restoreFolder(folder),
                onRename: () => _renameFolder(folder),

                onPermanentDelete: () =>
                    _permanentlyDeleteFolder(folder),

                onToggleFavorite: () =>
                    _toggleFavorite(folder),

                onToggleArchived: () =>
                    _toggleArchived(folder),
              );
            },
          ),
        ),
        if (items.isEmpty &&
            !hasNotes &&
            _section != QuizSection.browse)
          SliverFillRemaining(
            hasScrollBody: false,
            child: QuizEmptyState(
              icon: switch (_section) {
                QuizSection.favorites => Icons.star_outline,
                QuizSection.archived => Icons.archive_outlined,
                QuizSection.trash => Icons.delete_outline,
                _ => Icons.folder_outlined,
              },
              title: switch (_section) {
                QuizSection.favorites => 'No favourite folders',
                QuizSection.archived => 'No archived folders',
                QuizSection.trash => 'Trash is empty',
                _ => '',
              },
              message: switch (_section) {
                QuizSection.favorites =>
                'Mark useful folders as favourites for quick access.',

                QuizSection.archived =>
                'Folders you archive will appear here.',

                QuizSection.trash =>
                'Deleted folders and quizzes will appear here.',

                _ => '',
              },
            ),
          ),
      ],
    );
  }

  List<Widget> _buildQuizSlivers(
      AsyncValue<List<QuizAttempt>> quizzes,
      bool hasFolders,
      ) {
    return quizzes.when(
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
            child: QuizErrorState(message: _friendlyError(error)),
          ),
        ),
      ],
      data: (items) => [
        if (items.isNotEmpty)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Quizzes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, index) {
              final quiz = items[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.quiz_outlined),
                  title: Text(quiz.name),
                  subtitle: Text(quiz.status.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizViewerScreen(
                          attempt: quiz,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (items.isEmpty &&
            !hasFolders &&
            _section != QuizSection.trash)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              48,
              20,
              24,
            ),
            sliver: SliverToBoxAdapter(
              child: QuizEmptyState(
                icon: _section == QuizSection.trash
                    ? Icons.delete_outline
                    : Icons.upload_file_outlined,
                title: _section == QuizSection.trash
                    ? 'Trash is empty'
                    : 'This folder is empty',
                message: _section == QuizSection.trash
                    ? 'Deleted quizzes will appear here.'
                    : 'Generate your first quiz or create a folder.',
              ),
            ),
          ),
      ],
    );
  }

  void _changeSection(QuizSection section) {
    setState(() {
      _section = section;
      _folderStack.clear();
    });
  }

  void _openFolder(QuizFolder folder) {
    if (_section == QuizSection.archived) return;

    setState(() {
      _section = QuizSection.browse;
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
      builder: (context) => const CreateQuizFolderDialog(),
    );
    if (!mounted || name == null) return;

    final created = await ref
        .read(
      quizLibraryActionControllerProvider.notifier,
    )
        .createQuizFolder(parentId: _folderId, name: name);
    if (!mounted) return;

    _showResult(created, successMessage: 'Folder created.');
  }

  Future<String?> _pickFolder({
    String? excludeFolderId,
  }) async {
    final folders =
    await ref.read(
      allFoldersProvider.future,
    );

    if (!mounted) return null;

    return showDialog<String>(
      context: context,
      builder: (_) => QuizFolderPickerDialog(
        folders: folders,
        excludeFolderId:
        excludeFolderId,
      ),
    );
  }

  Future<void> _moveFolder(
      QuizFolder folder,
      ) async {
    final destination =
    await _pickFolder(
      excludeFolderId: folder.id,
    );

    if (destination == null) return;

    final success = await ref
        .read(
      quizLibraryActionControllerProvider.notifier,
    )
        .moveQuizFolder(
      folderId: folder.id,
      destinationFolderId:
      destination,
    );

    if (!mounted) return;

    _showResult(
      success,
      successMessage:
      'Folder moved successfully.',
    );
  }

  Future<void> _renameFolder(
      QuizFolder folder,
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
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value =
                controller.text.trim();

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
      quizLibraryActionControllerProvider.notifier,
    )
        .renameQuizFolder(
      folderId: folder.id,
      name: name,
    );

    if (!mounted) return;

    _showResult(
      success,
      successMessage:
      'Folder renamed successfully.',
    );
  }

  Future<void> _moveFolderToTrash(QuizFolder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Move folder to Trash?'),
        content: const Text(
          'This folder, all nested folders, and all quizzes inside them '
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
        .read(quizLibraryActionControllerProvider.notifier)
        .softDeleteQuizFolder(folder);

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Folder moved to Trash.',
    );
  }

  Future<void> _restoreFolder(QuizFolder folder) async {
    final success = await ref
        .read(quizLibraryActionControllerProvider.notifier)
        .restoreQuizFolder(folder);

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Folder restored.',
    );
  }

  Future<void> _permanentlyDeleteFolder(
      QuizFolder folder,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: const Text(
          'This folder, all child folders, and all quizzes inside it '
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
        .read(quizLibraryActionControllerProvider.notifier)
        .permanentlyDeleteFolder(folder);

    if (!mounted) return;

    _showResult(
      success,
      successMessage: 'Folder permanently deleted.',
    );
  }

  Future<void> _toggleFavorite(QuizFolder folder) async {
    final success = await ref
        .read(
      quizLibraryActionControllerProvider.notifier,
    )
        .setQuizFolderFavorite(folder, !folder.isFavorite);
    if (!mounted) return;
    _showResult(
      success,
      successMessage: folder.isFavorite
          ? 'Removed from favourites.'
          : 'Added to favourites.',
    );
  }

  Future<void> _toggleArchived(QuizFolder folder) async {
    final success = await ref
        .read(quizLibraryActionControllerProvider.notifier)
        .setQuizFolderArchived(folder, !folder.isArchived);
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
    final error = ref.read(quizLibraryActionControllerProvider).error;
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