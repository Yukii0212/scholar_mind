import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notes/providers/export_cart_items_provider.dart';
import '../providers/export_selection_provider.dart';
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

    final selection = ref.watch(
      exportSelectionNotifierProvider,
    );

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16,
          ),
          child: FilledButton(
            onPressed: () {
              // TODO: Open export method bottom sheet.
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Export',
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
        ),
      ),
      appBar: AppBar(
        titleSpacing: 8,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          tooltip: 'Back to Library',
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
              Text(
                'Export Cart',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'Going back to the library keeps your selected items.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ExportCartHeader(
                itemCount: selection.totalSelected,
              ),
              const SizedBox(
                height: 20,
              ),
              ExportCartModuleCard(
                icon: Icons.folder_copy_outlined,
                title: 'Notes',
                subtitle:
                '${selection.totalSelected} items',
                children: items
                    .map(
                      (item) => ExportCartNoteTile(
                    item: item,
                  ),
                )
                    .toList(),
              ),
              const SizedBox(
                height: 96,
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