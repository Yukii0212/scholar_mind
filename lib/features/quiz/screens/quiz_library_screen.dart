import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../core/theme/app_design.dart';
import '../../../core/widgets/collapsible_breadcrumb.dart';
import '../../help/widgets/help_anchor.dart';
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
      } else {
        _folderStack.removeRange(
          index + 1,
          _folderStack.length,
        );
      }
    });
  }

  String get _title {
    if (_section == QuizLibrarySection.library && _folderStack.isNotEmpty) {
      return _folderStack.last.name;
    }

    return switch (_section) {
      QuizLibrarySection.continueSection => 'Resume',
      QuizLibrarySection.library => 'Quiz Library',
      QuizLibrarySection.trash => 'Trash',
    };
  }

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
      floatingActionButton: HelpAnchor(
        pageId: '/quiz',
        anchorId: 'quiz-fab',
        child: SpeedDial(

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
              Icons.bolt_rounded,
            ),

            label: 'Quick Quiz',

            onTap: () {

              Navigator.push(

                context,

                MaterialPageRoute(
                  builder: (_) =>
                  const GenerateQuizScreen(quickMode: true),
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
      ),
      body: ListView(
        padding:
        const EdgeInsets.fromLTRB(20, 12, 20, 20),
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ScholarSectionHeader(
                title: _title,
                subtitle: _subtitle,
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

          SizedBox(
            width: double.infinity,
            child: HelpAnchor(
              pageId: '/quiz',
              anchorId: 'section-tabs',
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
          ),

          const SizedBox(height: 20),

          switch (_section) {

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

          if (isRoot) ...[
            const SizedBox(height: 24),
            Center(
              child: HelpAnchor(
                pageId: '/quiz',
                anchorId: 'flagged-questions-button',
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.outline,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(
                            alpha: 0.4,
                          ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuizFeedbackScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.flag_outlined, size: 16),
                  label: const Text('Flagged Questions'),
                ),
              ),
            ),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
