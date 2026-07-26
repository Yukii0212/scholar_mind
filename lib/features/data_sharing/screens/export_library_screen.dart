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
        icon: const Icon(
          Icons.arrow_forward_rounded,
        ),
        label: const Text(
          'Continue',
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: ExportSearchBar(),
          ),
          const Padding(
            padding:
            EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child:
            ExportSelectionSummary(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: ListView(
                children: const [

                  ExportModuleSection(
                    title: 'Notes',
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