import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_library_provider.dart'
as quiz_library;

import '../domain/quiz_folder.dart';
import '../domain/quiz_attempt.dart';

class QuizTrashSection extends ConsumerWidget {

  const QuizTrashSection({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {

    final deletedFoldersAsync = ref.watch(
      quiz_library.deletedFoldersProvider,
    );

    final deletedQuizzesAsync = ref.watch(
      quiz_library.deletedQuizzesProvider,
    );

    final actionController = ref.read(
      quiz_library
          .quizLibraryActionControllerProvider
          .notifier,
    );

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Text(

              'Trash',

              style: Theme.of(context)
                  .textTheme
                  .titleLarge,

            ),

            const SizedBox(height: 20),

            deletedFoldersAsync.when(

              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),

              error: (_, __) => const Text(
                'Failed to load folders.',
              ),

              data: (folders) {

                if (folders.isEmpty) {
                  return const SizedBox();
                }

                return Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(

                      'Folders',

                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,

                    ),

                    const SizedBox(height: 8),

                    ...folders.map(

                          (folder) => ListTile(

                            leading: const Icon(
                              Icons.folder_outlined,
                            ),

                            title: Text(
                              folder.name,
                            ),

                            subtitle: const Text(
                              'Folder',
                            ),

                            trailing: PopupMenuButton(

                              itemBuilder: (_) => const [

                                PopupMenuItem(

                                  value: 'restore',

                                  child: Text(
                                    'Restore',
                                  ),

                                ),

                                PopupMenuItem(

                                  value: 'delete',

                                  child: Text(
                                    'Delete Permanently',
                                  ),

                                ),

                              ],

                              onSelected: (value) async {

                                switch (value) {

                                  case 'restore':

                                    await actionController
                                        .restoreQuizFolder(
                                      folder,
                                    );

                                    break;

                                  case 'delete':

                                    final confirmed =
                                    await showDialog<bool>(

                                      context: context,

                                      builder: (dialogContext) =>
                                          AlertDialog(

                                            title: const Text(
                                              'Delete permanently?',
                                            ),

                                            content: const Text(
                                              'This folder, all child folders, and all quizzes inside it will be permanently deleted.\n\n'
                                                  'This action cannot be undone.',
                                            ),

                                            actions: [

                                              TextButton(

                                                onPressed: () =>
                                                    Navigator.pop(
                                                      dialogContext,
                                                      false,
                                                    ),

                                                child: const Text(
                                                  'Cancel',
                                                ),

                                              ),

                                              FilledButton(

                                                onPressed: () =>
                                                    Navigator.pop(
                                                      dialogContext,
                                                      true,
                                                    ),

                                                child: const Text(
                                                  'Delete',
                                                ),

                                              ),

                                            ],

                                          ),

                                    );

                                    if (confirmed != true) {
                                      return;
                                    }

                                    await actionController
                                        .permanentlyDeleteFolder(
                                      folder,
                                    );

                                    break;

                                }

                              },

                            ),

                          ),

                    ),

                  ],

                );

              },

            ),

            const SizedBox(height: 20),

            deletedQuizzesAsync.when(

              loading: () => const SizedBox(),

              error: (_, __) => const Text(
                'Failed to load quizzes.',
              ),

              data: (quizzes) {

                if (quizzes.isEmpty) {

                  return const SizedBox();

                }

                return Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(

                      'Quizzes',

                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,

                    ),

                    const SizedBox(height: 8),

                    ...quizzes.map(

                          (quiz) => ListTile(

                            leading: const Icon(
                              Icons.quiz_outlined,
                            ),

                            title: Text(
                              quiz.name,
                            ),

                            subtitle: const Text(
                              'Quiz',
                            ),

                            trailing: PopupMenuButton(

                              itemBuilder: (_) => const [

                                PopupMenuItem(

                                  value: 'restore',

                                  child: Text(
                                    'Restore',
                                  ),

                                ),

                                PopupMenuItem(

                                  value: 'delete',

                                  child: Text(
                                    'Delete Permanently',
                                  ),

                                ),

                              ],

                              onSelected: (value) async {

                                switch (value) {

                                  case 'restore':

                                    await actionController
                                        .restoreQuiz(
                                      quiz,
                                    );

                                    break;

                                  case 'delete':

                                    final confirmed =
                                    await showDialog<bool>(

                                      context: context,

                                      builder: (dialogContext) =>
                                          AlertDialog(

                                            title: const Text(
                                              'Delete permanently?',
                                            ),

                                            content: const Text(
                                              'This quiz will be permanently deleted.\n\n'
                                                  'This action cannot be undone.',
                                            ),

                                            actions: [

                                              TextButton(

                                                onPressed: () =>
                                                    Navigator.pop(
                                                      dialogContext,
                                                      false,
                                                    ),

                                                child: const Text(
                                                  'Cancel',
                                                ),

                                              ),

                                              FilledButton(

                                                onPressed: () =>
                                                    Navigator.pop(
                                                      dialogContext,
                                                      true,
                                                    ),

                                                child: const Text(
                                                  'Delete',
                                                ),

                                              ),

                                            ],

                                          ),

                                    );

                                    if (confirmed != true) {
                                      break;
                                    }

                                    await actionController
                                        .permanentlyDeleteQuiz(
                                      quiz,
                                    );

                                    break;

                                }

                              },

                            ),

                          ),

                    ),

                  ],

                );

              },

            ),

            if ((deletedFoldersAsync.valueOrNull?.isEmpty ?? true) &&
                (deletedQuizzesAsync.valueOrNull?.isEmpty ?? true))
              const Padding(

                padding: EdgeInsets.symmetric(
                  vertical: 24,
                ),

                child: Center(

                  child: Text(
                    'Trash is empty.',
                  ),

                ),

              ),

          ],

        ),

      ),

    );

  }

}