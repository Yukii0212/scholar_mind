import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/export/export_selection_count_provider.dart';

class ExportBottomBar
    extends ConsumerWidget {
  const ExportBottomBar({
    super.key,
    required this.onContinue,
  });

  final VoidCallback onContinue;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final count = ref.watch(
      exportSelectionCountProvider,
    );

    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed:
          count == 0
              ? null
              : onContinue,
          icon: const Icon(
            Icons.arrow_forward,
          ),
          label: Text(
            'Continue ($count)',
          ),
        ),
      ),
    );
  }
}