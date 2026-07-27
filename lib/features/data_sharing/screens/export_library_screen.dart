import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/export/export_module.dart';
import '../providers/export_summary_provider.dart';
import '../notes/widgets/export_module_tree.dart';
import '../widgets/screen/library/export_flat_item_list.dart';
import '../widgets/screen/library/export_grouped_item_list.dart';
import '../widgets/screen/library/export_module_section.dart';
import 'export_cart_screen.dart';

class ExportLibraryScreen
    extends ConsumerWidget {
  const ExportLibraryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final summary = ref.watch(
      exportSummaryProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Export Library',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: ListView(
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 112,
          ),
          children: const [
            ExportModuleSection(
              title: 'Notes',
              subtitle: 'Export folders and study materials',
              child: ExportModuleTree(
                module: ExportModule.notes,
              ),
            ),
            ExportModuleSection(
              title: 'Countdowns',
              subtitle: 'Export assignments, exams and other deadlines',
              child: ExportFlatItemList(
                moduleGroupId: 'countdowns',
              ),
            ),
            ExportModuleSection(
              title: 'Flashcards',
              subtitle: 'Export flashcard decks',
              child: ExportFlatItemList(
                moduleGroupId: 'flashcards',
              ),
            ),
            ExportModuleSection(
              title: 'Quizzes',
              subtitle: 'Export quizzes, grouped by folder',
              child: ExportGroupedItemList(
                moduleGroupId: 'quizzes',
              ),
            ),
            ExportModuleSection(
              title: 'Grades',
              subtitle: 'Export semesters, courses and grade entries',
              child: ExportFlatItemList(
                moduleGroupId: 'grades',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${summary.totalItems} item${summary.totalItems == 1 ? '' : 's'} selected',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
              ),
              FilledButton(
                onPressed: summary.totalItems == 0
                    ? null
                    : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                      const ExportCartScreen(),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continue',
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}