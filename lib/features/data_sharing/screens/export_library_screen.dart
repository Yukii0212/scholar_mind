import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/export_summary_provider.dart';
import '../notes/widgets/export_module_tree.dart';
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
              child: ExportModuleTree(),
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