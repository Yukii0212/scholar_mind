import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_mind/features/quiz/screens/quiz_result_screen.dart';
import 'package:scholar_mind/features/quiz/screens/quiz_viewer_screen.dart';

import '../domain/quiz_attempt.dart';
import '../domain/quiz_folder.dart';
import '../providers/quiz_library_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/quiz_folder_dialogs.dart';
import '../widgets/quiz_folder_picker_dialog.dart';
import '../domain/quiz_sort_order.dart';
import 'package:scholar_mind/features/quiz/screens/generate_quiz_screen.dart';

class QuizLibraryScreen extends ConsumerWidget {

  const QuizLibraryScreen({

    super.key,

    this.folderId = QuizFolder.rootId,

  });

  final String folderId;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final activeQuizzes =
    ref.watch(
      activeQuizzesProvider,
    );

    return Scaffold(
      floatingActionButton:
      FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text(
          'Generate Quiz',
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const GenerateQuizScreen(),
            ),
          );
        },
      ),
      body: ListView(
        padding:
        const EdgeInsets.all(20),
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                'Quiz Library',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall,
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(

                  icon: const Icon(
                    Icons.create_new_folder,
                  ),

                  label: const Text(
                    'New Folder',
                  ),

                  onPressed: () async {

                    final folderName =
                    await showDialog<String>(

                      context: context,

                      builder: (_) =>
                      const CreateQuizFolderDialog(),

                    );

                    if (folderName == null) {
                      return;
                    }

                    if (!context.mounted) {
                      return;
                    }

                    await ref
                        .read(
                      quizLibraryActionControllerProvider.notifier,
                    )
                        .createQuizFolder(
                      parentId: folderId,
                      name: folderName,
                    );

                  },

                ),
              ),

            ],
          ),

          const SizedBox(height: 24),

          if (activeQuizzes.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Continue',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),

                    const SizedBox(height: 16),

                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      itemCount: activeQuizzes.length,
                      separatorBuilder:
                          (_, __) =>
                      const SizedBox(height: 12),
                      itemBuilder:
                          (context, index) {

                        final item =
                        activeQuizzes[index];

                        return Card(
                          margin: EdgeInsets.zero,
                          child: ExpansionTile(

                            leading: Icon(

                              switch (item.status) {

                                QuizAttemptStatus.inProgress =>
                                Icons.play_circle_fill,

                                QuizAttemptStatus.grading =>
                                Icons.hourglass_top,

                                QuizAttemptStatus.completed =>
                                Icons.check_circle,

                                QuizAttemptStatus.archived =>
                                Icons.archive,

                              },

                            ),

                            title: Text(
                              item.name,
                              maxLines: 2,
                              overflow:
                              TextOverflow.ellipsis,
                            ),

                            subtitle: Text(

                              switch (item.status) {

                                QuizAttemptStatus.inProgress =>
                                '${item.answers.length}'
                                    ' / '
                                    '${item.quiz.questions.length}'
                                    ' Questions Answered',

                                QuizAttemptStatus.grading =>
                                'Waiting for AI grading...',

                                QuizAttemptStatus.completed =>
                                'Results Ready',

                                QuizAttemptStatus.archived =>
                                'Archived',

                              },

                            ),

                            childrenPadding:
                            const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),

                            children: [

                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(

                                  icon: Icon(

                                    item.status ==
                                        QuizAttemptStatus.inProgress
                                        ? Icons.play_arrow
                                        : Icons.visibility,

                                  ),

                                  label: Text(

                                    item.status ==
                                        QuizAttemptStatus.inProgress
                                        ? 'Continue'
                                        : 'View Results',

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
                                            quiz: item.quiz,
                                            answers: item.answers,
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
                                  onPressed: () {
                                    // TODO
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
                                      quizLibraryActionControllerProvider.notifier,
                                    )
                                        .renameQuiz(
                                      quizId: item.id,
                                      name: newName,
                                    );

                                  },
                                ),
                              ),

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
                                      allFoldersProvider.future,
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
                                      quizLibraryActionControllerProvider.notifier,
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
                                      quizLibraryActionControllerProvider.notifier,
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
                ),
              ),
            )
          else
    const SizedBox(height: 20),

          Card(
            child: Padding(
              padding:
              const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          'History',
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
      quizzesInFolderProvider(
        folderId,
      ),
    );

    final foldersAsync = ref.watch(
      childFoldersProvider(
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

trailing: const Icon(
Icons.chevron_right,
),

onTap: () {

Navigator.push(

context,

MaterialPageRoute(

builder: (_) => QuizLibraryScreen(
folderId: folder.id,
),

),

);

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
                                              quiz: item.quiz,
                                              answers: item.answers,
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
                                    onPressed: () {
                                      // TODO
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
                                        quizLibraryActionControllerProvider.notifier,
                                      )
                                          .renameQuiz(
                                        quizId: item.id,
                                        name: newName,
                                      );

                                    },
                                  ),
                                ),

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
                                        allFoldersProvider.future,
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
                                        quizLibraryActionControllerProvider.notifier,
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
                                        quizLibraryActionControllerProvider.notifier,
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
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}