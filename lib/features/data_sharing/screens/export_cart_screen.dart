import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notes/providers/export_cart_items_provider.dart';
import '../widgets/export_cart_summary.dart';
import '../widgets/export_cart_tile.dart';

class ExportCartScreen
    extends ConsumerWidget {
  const ExportCartScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final cart = ref.watch(
      exportCartItemsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Export Cart',
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding:
            EdgeInsets.all(16),
            child:
            ExportCartSummary(),
          ),
          Expanded(
            child: cart.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nothing selected.',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount:
                  items.length,
                  itemBuilder:
                      (context, index) {
                    return ExportCartTile(
                      item:
                      items[index],
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
            ),
          ),
        ],
      ),
    );
  }
}