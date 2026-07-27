import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notes/providers/export_library_provider.dart';
import '../../../notes/widgets/export_item_tile.dart';

class ExportFlatItemList extends ConsumerWidget {
  const ExportFlatItemList({
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
            ? const []
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

        return ListView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ExportItemTile(
              item: items[index],
            );
          },
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
