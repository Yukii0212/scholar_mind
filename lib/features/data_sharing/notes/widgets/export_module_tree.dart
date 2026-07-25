import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/export_tree_provider.dart';
import 'export_tree_tile.dart';

class ExportModuleTree
    extends ConsumerWidget {
  const ExportModuleTree({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final tree = ref.watch(
      exportTreeProvider,
    );

    return tree.when(
      data: (nodes) {
        return ListView.builder(
          itemCount: nodes.length,
          itemBuilder:
              (context, index) {
            return ExportTreeTile(
              node: nodes[index],
            );
          },
        );
      },
      loading:
          () => const Center(
        child:
        CircularProgressIndicator(),
      ),
      error:
          (e, _) => Center(
        child: Text(
          e.toString(),
        ),
      ),
    );
  }
}