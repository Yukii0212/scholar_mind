import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/export_statistics_provider.dart';

class ExportCartSummary
    extends ConsumerWidget {
  const ExportCartSummary({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final statistics = ref.watch(
      exportStatisticsProvider,
    );

    return statistics.when(
      data: (stats) {
        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.inventory_2_rounded,
            ),
            title: const Text(
              'Ready to Export',
            ),
            subtitle: Text(
              '${stats.selectedItems} items\n'
                  '${stats.selectedFolders} folders',
            ),
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}