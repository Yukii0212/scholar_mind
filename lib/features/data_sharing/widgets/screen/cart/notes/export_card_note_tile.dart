import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/share/share_resource_type.dart';
import '../../../../notes/model/export_cart_item.dart';
import '../../../../notes/model/export_item.dart';
import '../../../../notes/providers/export_library_provider.dart';
import '../../../../providers/export_selection_provider.dart';
import '../item/export_cart_item_tile.dart';
import '../shared/export_cart_icon_container.dart';

class ExportCartNoteTile extends ConsumerWidget {
  const ExportCartNoteTile({
    super.key,
    required this.item,
  });

  final ExportCartItem item;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: _buildDismissBackground(
        context,
        Alignment.centerLeft,
      ),
      secondaryBackground: _buildDismissBackground(
        context,
        Alignment.centerRight,
      ),
      confirmDismiss: (_) async {
        final modules = await ref.read(
          exportLibraryProvider.future,
        );

        final selections =
        <ShareResourceType, Set<String>>{};

        for (final module in modules) {
          final root = module.items.where(
                (e) => e.id == item.id,
          );

          if (root.isEmpty) {
            continue;
          }

          void collect(
              ExportItem current,
              ) {
            selections
                .putIfAbsent(
              current.type,
                  () => <String>{},
            )
                .add(current.id);

            for (final child in module.items.where(
                  (e) => e.parentId == current.id,
            )) {
              collect(child);
            }
          }

          collect(root.first);
          break;
        }

        ref
            .read(
          exportSelectionNotifierProvider
              .notifier,
        )
            .unselectAll(
          selections,
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Removed "${item.name}"',
              ),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  ref
                      .read(
                    exportSelectionNotifierProvider
                        .notifier,
                  )
                      .selectAll(
                    selections,
                    item.module,
                  );
                },
              ),
            ),
          );

        return false;
      },
      child: ExportCartItemTile(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              ExportCartIconContainer(
                child: Icon(
                  _icon,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        if (item.type.name ==
                            'noteFolder') ...[
                          if (item.childCount > 0)
                            _MetadataChip(
                              icon:
                              Icons.folder_outlined,
                              text:
                              '${item.childCount} subfolders',
                            ),
                          if (item.noteCount > 0)
                            _MetadataChip(
                              icon: Icons
                                  .description_outlined,
                              text:
                              '${item.noteCount} notes',
                            ),
                        ] else
                          _MetadataChip(
                            icon: Icons
                                .insert_drive_file_outlined,
                            text: item.type.name,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    switch (item.type.name) {
      case 'noteFolder':
        return Icons.folder_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}

Widget _buildDismissBackground(
    BuildContext context,
    Alignment alignment,
    ) {
  return Container(
    alignment: alignment,
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context)
          .colorScheme
          .error,
      borderRadius:
      BorderRadius.circular(12),
    ),
    child: Icon(
      Icons.delete_outline_rounded,
      color: Theme.of(context)
          .colorScheme
          .onError,
    ),
  );
}