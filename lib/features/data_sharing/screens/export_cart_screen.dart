import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notes/providers/export_cart_items_provider.dart';
import '../widgets/screen/cart/export_cart_header.dart';
import '../widgets/screen/cart/module/export_cart_module_card.dart';
import '../widgets/screen/cart/notes/export_card_note_tile.dart';

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
              ExportCartModuleCard(
                icon: Icons.folder_copy_outlined,
                title: 'Notes',
                subtitle: '${items.length} items',
                children: items
                    .map(
                      (item) => ExportCartNoteTile(
                    item: item,
                  ),
                )
                    .toList(),
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