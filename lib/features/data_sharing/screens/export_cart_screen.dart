import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_mind/features/data_sharing/screens/share_screen.dart';

import '../domain/models/export/export_module.dart';
import '../notes/model/export_cart_item.dart';
import '../notes/providers/export_cart_items_provider.dart';
import '../providers/export_selection_provider.dart';
import '../widgets/screen/cart/export_cart_header.dart';
import '../widgets/screen/cart/export_cart_swipe_hint.dart';
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
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ShareScreen(),
                ),
              );
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

          final itemsByModule =
          <ExportModule, List<ExportCartItem>>{};

          for (final item in items) {
            itemsByModule
                .putIfAbsent(
              item.module,
                  () => [],
            )
                .add(item);
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
              const ExportCartSwipeHint(),
              const SizedBox(
                height: 20,
              ),
              ExportCartHeader(
                itemCount: selection.totalSelected,
              ),
              const SizedBox(
                height: 20,
              ),
              for (final entry in itemsByModule.entries) ...[
                ExportCartModuleCard(
                  icon: _iconForModule(entry.key),
                  title: _titleForModule(entry.key),
                  subtitle:
                  '${entry.value.length} item${entry.value.length == 1 ? '' : 's'}',
                  children: entry.value
                      .map(
                        (item) => ExportCartNoteTile(
                      item: item,
                    ),
                  )
                      .toList(),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
              const SizedBox(
                height: 80,
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

IconData _iconForModule(
    ExportModule module,
    ) {
  return switch (module) {
    ExportModule.notes => Icons.folder_copy_outlined,
    ExportModule.flashcards => Icons.style_outlined,
    ExportModule.quizzes => Icons.quiz_outlined,
    ExportModule.countdowns => Icons.timer_outlined,
    ExportModule.grades => Icons.school_outlined,
  };
}

String _titleForModule(
    ExportModule module,
    ) {
  return switch (module) {
    ExportModule.notes => 'Notes',
    ExportModule.flashcards => 'Flashcards',
    ExportModule.quizzes => 'Quizzes',
    ExportModule.countdowns => 'Countdowns',
    ExportModule.grades => 'Grades',
  };
}