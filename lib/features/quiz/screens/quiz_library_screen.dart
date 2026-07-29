import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../core/theme/app_design.dart';
import '../../../core/widgets/collapsible_breadcrumb.dart';
import '../domain/quiz_folder.dart';
import '../providers/quiz_library_provider.dart'
as quiz_library;

import '../widgets/quiz_folder_dialogs.dart';
import '../domain/quiz_library_section.dart';
import 'package:scholar_mind/features/quiz/screens/generate_quiz_screen.dart';
import '../widgets/quiz_continue_section.dart';
import '../widgets/quiz_library_section_widget.dart';
import '../widgets/quiz_trash_section.dart';
import 'quiz_feedback_screen.dart';

class QuizLibraryScreen
    extends ConsumerStatefulWidget {
  const QuizLibraryScreen({
    super.key,
  });

  @override
  ConsumerState<QuizLibraryScreen>
  createState() =>
      _QuizLibraryScreenState();
}

class _QuizLibraryScreenState
    extends ConsumerState<QuizLibraryScreen> {
  final List<QuizFolder> _folderStack = [];

  QuizLibrarySection _section =
      QuizLibrarySection.continueSection;

  String get _folderId =>
      _folderStack.isEmpty
          ? QuizFolder.rootId
          : _folderStack.last.id;

  void _openFolder(QuizFolder folder) {
    setState(() {
      _section = QuizLibrarySection.library;

      if (_folderStack.isEmpty ||
          _folderStack.last.id != folder.id) {
        _folderStack.add(folder);
      }
    });
  }

  void _openBreadcrumb(int index) {
    setState(() {
      if (index < 0) {
        _folderStack.clear();
        _section = QuizLibrarySection.continueSection;
      } else {
        _folderStack.removeRange(
          index + 1,
          _folderStack.length,
        );
      }
    });
  }

  String get _title => switch (_section) {
        QuizLibrarySection.continueSection => 'Resume',
        QuizLibrarySection.library => 'Quiz Library',
        QuizLibrarySection.trash => 'Trash',
      };

  String get _subtitle => switch (_section) {
        QuizLibrarySection.continueSection =>
          'Quizzes waiting to be finished',
        QuizLibrarySection.library => 'Organize and access all your quizzes',
        QuizLibrarySection.trash => 'Deleted quizzes',
      };

  @override
  Widget build(
      BuildContext context,
      ) {
    final isRoot = _folderId == QuizFolder.rootId;

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
                parentId: _folderId,
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

              ScholarSectionHeader(
                title: isRoot ? _title : 'Quiz Library',
                subtitle: isRoot
                    ? _subtitle
                    : 'Organize and access all your quizzes',
                trailing: isRoot
                    ? IconButton(
                        icon: const Icon(Icons.flag_outlined),
                        tooltip: 'Flagged Questions',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QuizFeedbackScreen(),
                            ),
                          );
                        },
                      )
                    : null,
              ),

              const SizedBox(height: 12),

              CollapsibleBreadcrumb(
                homeLabel: 'My Quizzes',
                homeIcon: Icons.home_outlined,
                segments: [
                  for (final folder in _folderStack)
                    folder.name,
                ],
                onPressed: _openBreadcrumb,
              ),

              const SizedBox(height: 12),
            ],
          ),

          const SizedBox(height: 24),

        if (isRoot) ...[
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<QuizLibrarySection>(

            showSelectedIcon: false,

            segments: const [

              ButtonSegment(

                value:
                QuizLibrarySection.continueSection,

                icon: Icon(
                  Icons.play_circle_outline,
                ),

                tooltip: 'Resume',

              ),

              ButtonSegment(

                value: QuizLibrarySection.library,

                icon: Icon(
                  Icons.folder_outlined,
                ),

                tooltip: 'Library',

              ),

              ButtonSegment(

                value: QuizLibrarySection.trash,

                icon: Icon(
                  Icons.delete_outline,
                ),

                tooltip: 'Trash',

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
          ),

          const SizedBox(height: 20),

          ],

          switch (

          isRoot
              ? _section
              : QuizLibrarySection.library

          ) {

            QuizLibrarySection.continueSection =>

            const QuizContinueSection(),

            QuizLibrarySection.library =>

                QuizLibrarySectionWidget(
                  folderId: _folderId,
                  onOpenFolder: _openFolder,
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
