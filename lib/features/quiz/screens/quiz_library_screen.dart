import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/quiz_library_provider.dart';
import '../domain/quiz_sort_order.dart';
import 'package:scholar_mind/features/quiz/screens/generate_quiz_screen.dart';

class QuizLibraryScreen extends ConsumerWidget {
  const QuizLibraryScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
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

          Text(
            'Quiz Library',
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding:
              const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Text(
                    'Continue Quiz',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),

                  const SizedBox(height: 16),

                  const ListTile(
                    leading: Icon(
                      Icons.play_circle_fill,
                    ),
                    title: Text(
                      'No quiz in progress',
                    ),
                    subtitle: Text(
                      'Start a new quiz to begin studying.',
                    ),
                  ),
                ],
              ),
            ),
          ),

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

                      final library =
                      ref.watch(
                        quizLibraryProvider,
                      );

                      if (library.isEmpty) {
                        return const ListTile(
                          leading: Icon(
                            Icons.history,
                          ),
                          title: Text(
                            'No quizzes yet',
                          ),
                          subtitle: Text(
                            'Generate your first quiz to start building your quiz library.',
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        itemCount: library.length,
                        separatorBuilder:
                            (_, __) =>
                        const Divider(height: 1),
                        itemBuilder: (context, index) {

                          final item = library[index];

                          return ListTile(
                            leading: const Icon(
                              Icons.quiz,
                            ),
                            title: Text(item.title),
                            subtitle: Text(
                              item.attempt.status.name,
                            ),
                            trailing: PopupMenuButton<String>(
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'review',
                                  child: Text('Review'),
                                ),
                                PopupMenuItem(
                                  value: 'retake',
                                  child: Text('Retake'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
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