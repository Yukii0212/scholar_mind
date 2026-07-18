import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../core/theme/app_design.dart';
import '../domain/quiz_folder.dart';
import '../providers/quiz_library_provider.dart'
as quiz_library;

import '../widgets/quiz_folder_dialogs.dart';
import '../domain/quiz_library_section.dart';
import 'package:scholar_mind/features/quiz/screens/generate_quiz_screen.dart';
import '../widgets/quiz_continue_section.dart';
import '../widgets/quiz_library_section_widget.dart';
import '../widgets/quiz_trash_section.dart';

class QuizLibraryScreen
    extends ConsumerStatefulWidget {

  const QuizLibraryScreen({

    super.key,

    this.folderId = QuizFolder.rootId,

    this.initialSection,

  });

  final String folderId;

  final QuizLibrarySection? initialSection;

  @override
  ConsumerState<QuizLibraryScreen>
  createState() =>
      _QuizLibraryScreenState();

}

class _QuizLibraryScreenState
    extends ConsumerState<QuizLibraryScreen> {

  late QuizLibrarySection _section;

  @override
  void initState() {
    super.initState();

    _section =
        widget.initialSection ??
            (widget.folderId == QuizFolder.rootId
                ? QuizLibrarySection.continueSection
                : QuizLibrarySection.library);
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: SpeedDial(

        icon: Icons.add,
        activeIcon: Icons.close,

        spacing: 12,

        children: [

          SpeedDialChild(

            child: const Icon(
              Icons.quiz,
            ),

            label: 'New Quiz',

            onTap: () {

              Navigator.push(

                context,

                MaterialPageRoute(
                  builder: (_) =>
                  const GenerateQuizScreen(),
                ),

              );

            },

          ),

          SpeedDialChild(

            child: const Icon(
              Icons.create_new_folder,
            ),

            label: 'New Folder',

            onTap: () async {

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
                quiz_library
                    .quizLibraryActionControllerProvider
                    .notifier,
              )
                  .createQuizFolder(
                parentId: widget.folderId,
                name: folderName,
              );

            },

          ),

        ],

      ),
      body: ListView(
        padding:
        const EdgeInsets.fromLTRB(20, 12, 20, 20),
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const ScholarSectionHeader(
                title: 'Quiz Library',
                subtitle: 'Organize and access all your quizzes',
              ),

              const SizedBox(height: 12),

              ref.watch(
                quiz_library.folderPathProvider(
                  widget.folderId,
                ),
              ).when(

                loading: () =>
                const SizedBox.shrink(),

                error: (_, __) =>
                const SizedBox.shrink(),

                data: (path) {

                  return Wrap(

                    crossAxisAlignment:
                    WrapCrossAlignment.center,

                    spacing: 2,

                    children: [

                      TextButton.icon(

                        onPressed: () {

                          Navigator.pushAndRemoveUntil(

                            context,

                            MaterialPageRoute(
                              builder: (_) => const QuizLibraryScreen(),
                            ),

                                (route) => false,

                          );

                        },

                        icon: const Icon(
                          Icons.home_outlined,
                          size: 18,
                        ),

                        label: const Text(
                          'Home',
                        ),
                      ),

                      for (var i = 0;
                      i < path.length;
                      i++) ...[

                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                        ),

                        TextButton(

                          onPressed: () {

                            Navigator.pushAndRemoveUntil(

                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    QuizLibraryScreen(
                                      folderId: path[i].id,
                                    ),
                              ),

                                  (route) => false,

                            );

                          },

                          child: Text(
                            path[i].name,
                          ),

                        ),

                      ],

                    ],

                  );

                },

              ),

              const SizedBox(height: 12),
            ],
          ),

          const SizedBox(height: 24),

        if (widget.folderId == QuizFolder.rootId) ...[
          SegmentedButton<QuizLibrarySection>(

            segments: [

              if (widget.folderId == QuizFolder.rootId)
                const ButtonSegment(

                  value:
                  QuizLibrarySection.continueSection,

                  icon: Icon(
                    Icons.play_circle_outline,
                  ),

                  label: Text(
                    'Resume',
                  ),

                ),

              const ButtonSegment(

                value: QuizLibrarySection.library,

                icon: Icon(
                  Icons.folder_outlined,
                ),

                label: Text(
                  'Library',
                ),

              ),

              const ButtonSegment(

                value: QuizLibrarySection.trash,

                icon: Icon(
                  Icons.delete_outline,
                ),

                label: Text(
                  'Trash',
                ),

              ),

            ],

            selected: {

              _section,

            },

            onSelectionChanged: (selection) {

              setState(() {

                _section = selection.first;

              });

            },

          ),

          const SizedBox(height: 20),

          ],

          switch (

          widget.folderId == QuizFolder.rootId
              ? _section
              : QuizLibrarySection.library

          ) {

            QuizLibrarySection.continueSection =>

            const QuizContinueSection(),

            QuizLibrarySection.library =>

                QuizLibrarySectionWidget(
                  folderId: widget.folderId,
                ),

            QuizLibrarySection.trash =>

            const QuizTrashSection(),

          },

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
