import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/export_filtered_library_provider.dart';
import '../providers/export_summary_provider.dart';
import '../widgets/export_module_card.dart';
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
    final modules = ref.watch(
      exportFilteredLibraryProvider,
    );

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
            child: modules.when(
              data: (modules) {
                if (modules.isEmpty) {
                  return const Center(
                    child: Text(
                      'No study materials found.',
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.all(
                    16,
                  ),
                  itemCount:
                  modules.length,
                  itemBuilder:
                      (context, index) {
                    return ExportModuleCard(
                      module:
                      modules[index],
                    );
                  },
                );
              },
              loading: () =>
              const Center(
                child:
                CircularProgressIndicator(),
              ),
              error:
                  (error, stackTrace) =>
                  Center(
                    child: Text(
                      error.toString(),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}