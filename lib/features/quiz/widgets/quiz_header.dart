import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/widgets/collapsible_breadcrumb.dart';
import '../domain/quiz_enums.dart';
import '../domain/quiz_folder.dart';

class QuizHeader extends StatelessWidget {
  const QuizHeader({
    super.key,
    required this.section,
    required this.folderStack,
    required this.isBusy,
    required this.onSectionChanged,
    required this.onBreadcrumbPressed,
    required this.onCreateFolder,
    required this.onGenerateQuiz,
    required this.onRestoreAll,
    required this.onDeleteAll,
  });

  final QuizSection section;
  final List<QuizFolder> folderStack;
  final bool isBusy;
  final ValueChanged<QuizSection> onSectionChanged;
  final ValueChanged<int> onBreadcrumbPressed;
  final VoidCallback onCreateFolder;
  final VoidCallback onGenerateQuiz;
  final VoidCallback onRestoreAll;
  final VoidCallback onDeleteAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Quizzes', style: Theme.of(context).textTheme.headlineMedium),
        const Gap(4),
        Text(
          'Organise generated quizzes into folders.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(20),
        SegmentedButton<QuizSection>(
          segments: const [
            ButtonSegment(
              value: QuizSection.browse,
              icon: Icon(Icons.folder_outlined),
              label: Text('Library'),
            ),
            ButtonSegment(
              value: QuizSection.favorites,
              icon: Icon(Icons.star_outline),
              label: Text('Favourites'),
            ),
            ButtonSegment(
              value: QuizSection.archived,
              icon: Icon(Icons.archive_outlined),
              label: Text('Archived'),
            ),
            ButtonSegment(
              value: QuizSection.trash,
              icon: Icon(Icons.delete_outline),
              label: Text('Trash'),
            ),
          ],
          selected: {section},
          onSelectionChanged:
          isBusy ? null : (selection) => onSectionChanged(selection.first),
        ),
        if (section == QuizSection.browse) ...[
          const Gap(18),
          CollapsibleBreadcrumb(
            homeLabel: 'My Quizzes',
            homeIcon: Icons.home_outlined,
            segments: [
              for (final folder in folderStack) folder.name,
            ],
            onPressed: onBreadcrumbPressed,
          ),
          const Gap(10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: isBusy ? null : onCreateFolder,
                icon: const Icon(Icons.create_new_folder_outlined),
                label: const Text('New folder'),
              ),
              FilledButton.icon(
                onPressed: isBusy ? null : onGenerateQuiz,
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('Generate Quiz'),
              ),
            ],
          ),
        ],
        if (section == QuizSection.trash) ...[
          const Gap(18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: isBusy ? null : onRestoreAll,
                icon: const Icon(Icons.restore),
                label: const Text('Restore All'),
              ),
              FilledButton.icon(
                onPressed: isBusy ? null : onDeleteAll,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete All'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}