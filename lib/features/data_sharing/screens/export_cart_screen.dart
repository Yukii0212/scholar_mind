import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notes/providers/export_cart_items_provider.dart';
import '../widgets/screen/cart/export_cart_header.dart';
import '../widgets/screen/library/export_cart_summary.dart';
import '../widgets/screen/library/export_cart_tile.dart';

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
      body: cart.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Nothing selected.',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              96,
            ),
            children: [
              ExportCartHeader(
                itemCount: items.length,
              ),
              const SizedBox(
                height: 20,
              ),
              const ExportCartSummary(),
              const SizedBox(
                height: 20,
              ),
              ...items.map(
                    (item) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ExportCartTile(
                    item: item,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
          ),
        ),
      ),
    );
  }
}