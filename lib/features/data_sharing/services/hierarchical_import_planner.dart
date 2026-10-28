class HierarchicalImportPlan<T> {
  const HierarchicalImportPlan({
    required this.orderedItems,
    required this.detachedIds,
  });

  final List<T> orderedItems;
  final Set<String> detachedIds;
}

HierarchicalImportPlan<T> planHierarchicalImport<T>({
  required Iterable<T> items,
  required String Function(T item) idOf,
  required String Function(T item) parentIdOf,
  required bool Function(String parentId) isRootParent,
  required String resourceLabel,
}) {
  final itemsById = <String, T>{};

  for (final item in items) {
    final id = idOf(item);

    if (itemsById.containsKey(id)) {
      throw FormatException(
        'Duplicate $resourceLabel identifier "$id".',
      );
    }

    itemsById[id] = item;
  }

  final unresolved = Map<String, T>.from(itemsById);
  final resolvedIds = <String>{};
  final orderedItems = <T>[];
  final detachedIds = <String>{};

  while (unresolved.isNotEmpty) {
    var madeProgress = false;

    for (final entry in unresolved.entries.toList()) {
      final parentId = parentIdOf(entry.value);
      final parentIsMissing = !itemsById.containsKey(parentId);

      if (!isRootParent(parentId) &&
          !parentIsMissing &&
          !resolvedIds.contains(parentId)) {
        continue;
      }

      if (!isRootParent(parentId) && parentIsMissing) {
        detachedIds.add(entry.key);
      }

      orderedItems.add(entry.value);
      resolvedIds.add(entry.key);
      unresolved.remove(entry.key);
      madeProgress = true;
    }

    if (!madeProgress) {
      final ids = unresolved.keys.join(', ');
      throw FormatException(
        'Cyclic $resourceLabel hierarchy involving: $ids.',
      );
    }
  }

  return HierarchicalImportPlan<T>(
    orderedItems: List<T>.unmodifiable(orderedItems),
    detachedIds: Set<String>.unmodifiable(detachedIds),
  );
}
