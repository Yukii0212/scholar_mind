import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notes/providers/export_filtered_library_provider.dart';
import '../providers/export_summary_provider.dart';
import '../notes/widgets/export_module_tree.dart';
import '../widgets/export_module_section.dart';
import '../widgets/export_search_bar.dart';
import '../widgets/export_selection_summary.dart';
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
      floatingActionButton:
      FloatingActionButton.extended(
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
        backgroundColor: summary.totalItems == 0
            ? Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            : null,
        foregroundColor: summary.totalItems == 0
            ? Theme.of(context)
            .colorScheme
            .onSurfaceVariant
            : null,
        icon: const Icon(
          Icons.arrow_forward_rounded,
        ),
        label: Text(
          'Continue (${summary.totalItems})',
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: ExportSearchBar(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: ListView(
                children: const [
                  ExportModuleSection(
                    title: 'Notes',
                    subtitle:
                    'Export folders and study materials',
                    child: ExportModuleTree(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}