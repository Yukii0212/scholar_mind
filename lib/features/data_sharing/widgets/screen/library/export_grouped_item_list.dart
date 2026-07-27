import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notes/model/export_item.dart';
import '../../../notes/providers/export_library_provider.dart';
import '../../../notes/widgets/export_item_tile.dart';

class ExportGroupedItemList extends ConsumerWidget {
  const ExportGroupedItemList({
    super.key,
    required this.moduleGroupId,
  });

  final String moduleGroupId;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final library = ref.watch(
      exportLibraryProvider,
    );

    return library.when(
      data: (groups) {
        final matches = groups.where(
              (group) => group.id == moduleGroupId,
        );

        final items = matches.isEmpty
            ? const <ExportItem>[]
            : matches.first.items;

        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 24,
            ),
            child: Center(
              child: Text(
                'Nothing to export yet.',
              ),
            ),
          );
        }

        final grouped = <String, List<ExportItem>>{};

        for (final item in items) {
          grouped
              .putIfAbsent(
            item.groupLabel ?? 'Ungrouped',
                () => <ExportItem>[],
          )
              .add(item);
        }

        final groupLabels = grouped.keys.toList()
          ..sort();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final label in groupLabels) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  4,
                ),
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                itemCount: grouped[label]!.length,
                itemBuilder: (context, index) {
                  return ExportItemTile(
                    item: grouped[label]![index],
                  );
                },
              ),
            ],
          ],
        );
      },
      loading:
          () => const Center(
        child: CircularProgressIndicator(),
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
