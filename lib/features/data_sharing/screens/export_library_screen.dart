import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/export_summary_provider.dart';
import '../notes/widgets/export_module_tree.dart';
import '../widgets/export_module_section.dart';
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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: ListView(
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 96,
          ),
          children: const [
            ExportModuleSection(
              title: 'Notes',
              subtitle: 'Export folders and study materials',
              child: ExportModuleTree(),
            ),
          ],
        ),
      ),
    );
  }
}