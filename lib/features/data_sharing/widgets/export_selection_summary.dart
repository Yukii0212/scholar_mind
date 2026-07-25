import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/export_summary_provider.dart';

class ExportSelectionSummary
    extends ConsumerWidget {
  const ExportSelectionSummary({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(
      exportSummaryProvider,
    );

    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.checklist_rounded),
        ),
        title: const Text(
          'Export Selection',
        ),
        subtitle: Text(
          '${summary.totalItems} item(s) selected',
        ),
      ),
    );
  }
}