import 'package:flutter/material.dart';

import '../model/export_module_group.dart';
import 'export_item_tile.dart';

class ExportModuleCard extends StatelessWidget {
  const ExportModuleCard({
    super.key,
    required this.module,
  });

  final ExportModuleGroup module;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              module.title,
              style:
              Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),
            if (module.description != null) ...[
              const SizedBox(height: 4),
              Text(module.description!),
            ],
            const SizedBox(height: 16),
            for (final item in module.items)
              ExportItemTile(
                item: item,
              ),
          ],
        ),
      ),
    );
  }
}