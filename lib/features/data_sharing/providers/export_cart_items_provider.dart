import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/export/export_cart_item.dart';
import 'export_cart_provider.dart';

part 'export_cart_items_provider.g.dart';

@riverpod
Future<List<ExportCartItem>>
exportCartItems(
    ExportCartItemsRef ref,
    ) async {
  final items = await ref.watch(
    exportCartProvider.future,
  );

  return items
      .map(
        (item) => ExportCartItem(
      id: item.id,
      name: item.name,
      subtitle: item.subtitle,
      module: item.module,
      type: item.type,
      childCount: item.childCount,
      noteCount: item.noteCount,
    ),
  )
      .toList();
}