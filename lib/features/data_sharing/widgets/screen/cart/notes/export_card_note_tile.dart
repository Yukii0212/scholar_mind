import 'package:flutter/material.dart';

import '../../../../notes/model/export_cart_item.dart';
import '../item/export_cart_item_tile.dart';
import '../shared/export_cart_icon_container.dart';

class ExportCartNoteTile extends StatelessWidget {
  const ExportCartNoteTile({
    super.key,
    required this.item,
  });

  final ExportCartItem item;

  @override
  Widget build(BuildContext context) {
    return ExportCartItemTile(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExportCartIconContainer(
              child: Icon(
                _icon,
                size: 32,
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
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle!,
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
                        _MetadataChip(
                          icon: Icons.folder_outlined,
                          text:
                          '${item.childCount} subfolders',
                        ),
                        _MetadataChip(
                          icon: Icons.description_outlined,
                          text:
                          '${item.noteCount} notes',
                        ),
                      ] else
                        _MetadataChip(
                          icon: Icons.insert_drive_file_outlined,
                          text: item.type.name,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.delete_outline,
              ),
            ),
          ],
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