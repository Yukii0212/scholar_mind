import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_mind/features/quiz/widgets/quiz_folder_picker_dialog.dart';
import '../domain/quiz_attempt.dart';
import '../providers/quiz_attempt_provider.dart';
import '../providers/quiz_library_provider.dart'
as quiz_library;
import '../screens/quiz_result_screen.dart';
import '../screens/quiz_viewer_screen.dart';

class QuizContinueSection extends ConsumerWidget {

  const QuizContinueSection({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {

    final activeQuizzesAsync = ref.watch(
      quiz_library.activeQuizzesProvider,
    );

    return activeQuizzesAsync.when(
          loading: () =>
          const SizedBox.shrink(),

          error: (_, __) =>
          const SizedBox.shrink(),

          data: (activeQuizzes) {
            if (activeQuizzes.isEmpty) {

              return Card(

                child: Padding(

                  padding: const EdgeInsets.all(20),

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(

                        'Resume',

                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,

                      ),

                      const SizedBox(height: 16),

                      const ListTile(

                        leading: Icon(
                          Icons.check_circle_outline,
                        ),

                        title: Text(
                          'You\'re all caught up!',
                        ),

                        subtitle: Text(
                          'You have no quizzes waiting to be resumed.',
                        ),

                      ),

                    ],

                  ),

                ),

              );

            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Continue',
                      style: Theme
                          .of(context)
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
                                '${item.answeredCount}'
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

                                    if (newName == null || newName
                                        .trim()
                                        .isEmpty) {
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
                ),
              ),
            );
          },
    );
  }
}