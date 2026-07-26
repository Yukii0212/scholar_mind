import 'package:flutter/material.dart';
import '../../../notes/model/export_cart_item.dart';

class ExportCartTile extends StatelessWidget {
  const ExportCartTile({
    super.key,
    required this.item,
    this.onRemove,
  });

  final ExportCartItem item;

  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        item.isFolder
            ? Icons.folder_rounded
            : Icons.description_rounded,
      ),
      title: Text(item.name),
      subtitle: Text(
        item.subtitle ??
            item.module.name,
      ),
      trailing: IconButton(
        onPressed: onRemove,
        icon: const Icon(
          Icons.close_rounded,
        ),
      ),
    );
  }
}