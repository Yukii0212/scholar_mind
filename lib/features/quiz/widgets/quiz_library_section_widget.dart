import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_mind/core/theme/app_design.dart';
import 'package:scholar_mind/features/quiz/widgets/quiz_folder_picker_dialog.dart';

import '../domain/quiz_attempt.dart';
import '../domain/quiz_folder.dart';
import '../domain/quiz_sort_order.dart';
import '../providers/quiz_attempt_provider.dart';
import '../providers/quiz_library_provider.dart' as quiz_library;
import '../providers/quiz_provider.dart';
import '../screens/quiz_result_screen.dart';
import '../screens/quiz_viewer_screen.dart';

class QuizLibrarySectionWidget
    extends ConsumerWidget {

  const QuizLibrarySectionWidget({
    super.key,
    required this.folderId,
    required this.onOpenFolder,
  });

  final String folderId;

  final ValueChanged<QuizFolder> onOpenFolder;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {

    return ScholarPanel(
      child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                Expanded(
                  child: Text(
                    'Library',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                ),

                DropdownButton<QuizSortOrder>(
                  value: ref.watch(
                    quizSortOrderProvider,
                  ),
                  underline:
                  const SizedBox.shrink(),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(
                        quizSortOrderProvider
                            .notifier,
                      )
                          .state = value;
                    }
                  },
                  items: const [

                    DropdownMenuItem(
                      value:
                      QuizSortOrder
                          .lastOpened,
                      child: Text(
                        'Last Opened',
                      ),
                    ),

                    DropdownMenuItem(
                      value:
                      QuizSortOrder
                          .lastModified,
                      child: Text(
                        'Last Modified',
                      ),
                    ),

                    DropdownMenuItem(
                      value:
                      QuizSortOrder
                          .dateCreated,
                      child: Text(
                        'Date Created',
                      ),
                    ),

                    DropdownMenuItem(
                      value:
                      QuizSortOrder
                          .dateCompleted,
                      child: Text(
                        'Date Completed',
                      ),
                    ),

                    DropdownMenuItem(
                      value:
                      QuizSortOrder
                          .name,
                      child: Text(
                        'Name',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Builder(
              builder: (context) {
                final libraryAsync = ref.watch(
                  quiz_library.quizzesInFolderProvider(
                    folderId,
                  ),
                );

                final foldersAsync = ref.watch(
                  quiz_library.childFoldersProvider(
                    folderId,
                  ),
                );

                return libraryAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),

                  error: (error, _) => ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text(
                      'Failed to load quizzes',
                    ),
                    subtitle: Text(
                      error.toString(),
                    ),
                  ),

                  data: (library) {
                    final folders = foldersAsync.value ?? [];
                    if (folders.isEmpty &&
                        library.isEmpty) {
                      return const ListTile(
                        leading: Icon(Icons.history),
                        title: Text('No quizzes yet'),
                        subtitle: Text(
                          'Generate your first quiz to start building your quiz library.',
                        ),
                      );
                    }

                    return ListView(

                      shrinkWrap: true,

                      physics:
                      const NeverScrollableScrollPhysics(),

                      children: [

                        ...folders.map(

                              (folder) {

                            return Card(

                              margin: const EdgeInsets.only(
                                bottom: 12,
                              ),

                              child: ListTile(

                                leading: const Icon(
                                  Icons.folder,
                                ),

                                title: Text(
                                  folder.name,
                                ),

                                trailing: PopupMenuButton<String>(

                                  onSelected: (value) async {

                                    switch (value) {

                                      case 'rename':

                                        final controller =
                                        TextEditingController(
                                          text: folder.name,
                                        );

                                        final newName =
                                        await showDialog<String>(
                                          context: context,
                                          builder: (dialogContext) {

                                            return AlertDialog(

                                              title: const Text(
                                                'Rename Folder',
                                              ),

                                              content: TextField(
                                                controller: controller,
                                                autofocus: true,
                                                decoration:
                                                const InputDecoration(
                                                  labelText:
                                                  'Folder Name',
                                                ),
                                              ),

                                              actions: [

                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Cancel',
                                                  ),
                                                ),

                                                FilledButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                      controller.text.trim(),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Rename',
                                                  ),
                                                ),

                                              ],

                                            );

                                          },
                                        );

                                        if (newName == null ||
                                            newName.trim().isEmpty) {
                                          return;
                                        }

                                        await ref
                                            .read(
                                          quiz_library
                                              .quizLibraryActionControllerProvider
                                              .notifier,
                                        )
                                            .renameQuizFolder(
                                          folderId: folder.id,
                                          name: newName,
                                        );

                                        break;

                                      case 'move':

                                        final folders = await ref.read(
                                          quiz_library.allFoldersProvider.future,
                                        );

                                        if (!context.mounted) {
                                          return;
                                        }

                                        final destinationFolderId =
                                        await showDialog<String>(
                                          context: context,
                                          builder: (_) {
                                            return QuizFolderPickerDialog(
                                              folders: folders,
                                            );
                                          },
                                        );

                                        if (destinationFolderId == null) {
                                          return;
                                        }

                                        final success = await ref
                                            .read(
                                          quiz_library
                                              .quizLibraryActionControllerProvider
                                              .notifier,
                                        )
                                            .moveQuizFolder(
                                          folderId: folder.id,
                                          destinationFolderId:
                                          destinationFolderId,
                                        );

                                        if (!success && context.mounted) {

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(

                                            const SnackBar(

                                              content: Text(
                                                'That folder cannot be moved there.',
                                              ),

                                            ),

                                          );

                                        }

                                        break;

                                      case 'delete':

                                        final confirmed =
                                        await showDialog<bool>(
                                          context: context,
                                          builder: (dialogContext) {

                                            return AlertDialog(

                                              title: const Text(
                                                'Delete Folder?',
                                              ),

                                              content: Text(
                                                'Move "${folder.name}" and all of its subfolders and quizzes to Trash?',
                                              ),

                                              actions: [

                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                      false,
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Cancel',
                                                  ),
                                                ),

                                                FilledButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                      true,
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Delete',
                                                  ),
                                                ),

                                              ],

                                            );

                                          },
                                        );

                                        if (confirmed != true) {
                                          return;
                                        }

                                        await ref
                                            .read(
                                          quiz_library
                                              .quizLibraryActionControllerProvider
                                              .notifier,
                                        )
                                            .softDeleteQuizFolder(
                                          folder,
                                        );

                                        break;

                                    }

                                  },

                                  itemBuilder: (_) => const [

                                    PopupMenuItem(
                                      value: 'rename',
                                      child: Text(
                                        'Rename',
                                      ),
                                    ),

                                    PopupMenuItem(
                                      value: 'move',
                                      child: Text(
                                        'Move',
                                      ),
                                    ),

                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Delete',
                                      ),
                                    ),
                                  ],

                                ),

                                onTap: () {
                                  onOpenFolder(folder);
                                },

                              ),

                            );

                          },

                        ),

                        ...List.generate(
                          library.length,
                              (index) {
                            final item = library[index];

                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: ExpansionTile(
                                leading: const Icon(
                                  Icons.quiz,
                                ),

                                title: Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                subtitle: Text(

                                  switch (item.status) {

                                    QuizAttemptStatus.inProgress =>
                                    'In Progress',

                                    QuizAttemptStatus.grading =>
                                    'Waiting for AI',

                                    QuizAttemptStatus.completed =>
                                    'Completed',

                                    QuizAttemptStatus.archived =>
                                    'Archived',
                                  },

                                ),

                                childrenPadding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),

                                children: [

                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      icon: const Icon(
                                        Icons.play_arrow,
                                      ),
                                      label: Text(
                                        item.status ==
                                            QuizAttemptStatus.inProgress
                                            ? 'Continue'
                                            : 'Review',
                                      ),
                                      onPressed: () {

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {

                                              if (item.status ==
                                                  QuizAttemptStatus.inProgress) {
                                                return QuizViewerScreen(
                                                  attempt: item,
                                                );
                                              }

                                              return QuizResultScreen(
                                                attempt: item,
                                              );

                                            },
                                          ),
                                        );

                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.refresh,
                                      ),
                                      label: const Text(
                                        'Retry',
                                      ),
                                      onPressed: () async {

                                        final confirmed =
                                        await showDialog<bool>(
                                          context: context,
                                          builder: (dialogContext) {
                                            return AlertDialog(

                                              title: const Text(
                                                'Retry Quiz?',
                                              ),

                                              content: const Text(
                                                'This will reset all answers, score and AI feedback for this quiz.',
                                              ),

                                              actions: [

                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                      false,
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Cancel',
                                                  ),
                                                ),

                                                FilledButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                      true,
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Retry',
                                                  ),
                                                ),

                                              ],

                                            );
                                          },
                                        );

                                        if (confirmed != true) {
                                          return;
                                        }

                                        final controller = ref.read(
                                          quizAttemptProvider.notifier,
                                        );

                                        await controller.restoreAttempt(
                                          attempt: item,
                                        );

                                        await controller.retryAttempt();

                                        if (!context.mounted) {
                                          return;
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => QuizViewerScreen(
                                              attempt: controller.state!,
                                            ),
                                          ),
                                        );

                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.edit,
                                      ),
                                      label: const Text(
                                        'Rename',
                                      ),
                                      onPressed: () async {

                                        final controller = TextEditingController(
                                          text: item.name,
                                        );

                                        final newName = await showDialog<String>(
                                          context: context,
                                          builder: (dialogContext) {

                                            return AlertDialog(

                                              title: const Text(
                                                'Rename Quiz',
                                              ),

                                              content: TextField(
                                                controller: controller,
                                                autofocus: true,
                                                decoration: const InputDecoration(
                                                  labelText: 'Quiz Name',
                                                ),
                                              ),

                                              actions: [

                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(dialogContext);
                                                  },
                                                  child: const Text(
                                                    'Cancel',
                                                  ),
                                                ),

                                                FilledButton(
                                                  onPressed: () {

                                                    Navigator.pop(
                                                      dialogContext,
                                                      controller.text.trim(),
                                                    );

                                                  },
                                                  child: const Text(
                                                    'Rename',
                                                  ),
                                                ),

                                              ],

                                            );

                                          },
                                        );

                                        if (newName == null || newName.trim().isEmpty) {
                                          return;
                                        }

                                        if (!context.mounted) {
                                          return;
                                        }


                                        await ref
                                            .read(
                                          quiz_library.quizLibraryActionControllerProvider.notifier,
                                        )
                                            .renameQuiz(
                                          quizId: item.id,
                                          name: newName,
                                        );

                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Only in-progress/grading quizzes ever
                                  // show up in Continue in the first place,
                                  // so this only needs to appear for those
                                  // -- toggling it for a completed quiz
                                  // wouldn't do anything observable.
                                  if (item.status ==
                                          QuizAttemptStatus.inProgress ||
                                      item.status ==
                                          QuizAttemptStatus.grading)
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        icon: Icon(
                                          item.isArchived
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        label: Text(
                                          item.isArchived
                                              ? 'Restore to Continue'
                                              : 'Remove from Continue',
                                        ),
                                        onPressed: () async {
                                          await ref
                                              .read(
                                            quiz_library.quizLibraryActionControllerProvider.notifier,
                                          )
                                              .toggleQuizArchived(item);
                                        },
                                      ),
                                    ),

                                  if (item.status ==
                                          QuizAttemptStatus.inProgress ||
                                      item.status ==
                                          QuizAttemptStatus.grading)
                                    const SizedBox(height: 8),

                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.drive_file_move,
                                      ),
                                      label: const Text(
                                        'Move',
                                      ),
                                      onPressed: () async {

                                        final folders = await ref
                                            .read(
                                          quiz_library.allFoldersProvider.future,
                                        );

                                        final destinationFolderId =
                                        await showDialog<String>(
                                          context: context,
                                          builder: (_) {

                                            return QuizFolderPickerDialog(
                                              folders: folders,
                                            );

                                          },
                                        );

                                        if (destinationFolderId == null) {
                                          return;
                                        }

                                        await ref
                                            .read(
                                          quiz_library.quizLibraryActionControllerProvider.notifier,
                                        )
                                            .moveQuiz(
                                          quizId: item.id,
                                          destinationFolderId:
                                          destinationFolderId,
                                        );

                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                      ),
                                      label: const Text(
                                        'Delete',
                                      ),
                                      onPressed: () async {

                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (dialogContext) {

                                            return AlertDialog(

                                              title: const Text(
                                                'Delete Quiz?',
                                              ),

                                              content: Text(
                                                'Move "${item.name}" to Trash?',
                                              ),

                                              actions: [

                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                      false,
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Cancel',
                                                  ),
                                                ),

                                                FilledButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                      true,
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Delete',
                                                  ),
                                                ),

                                              ],

                                            );

                                          },
                                        );

                                        if (confirmed != true) {
                                          return;
                                        }

                                        await ref
                                            .read(
                                          quiz_library.quizLibraryActionControllerProvider.notifier,
                                        )
                                            .softDeleteQuiz(
                                          item,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
    );
  }
}
