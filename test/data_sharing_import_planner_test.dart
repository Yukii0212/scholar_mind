import 'package:flutter_test/flutter_test.dart';
import 'package:scholar_mind/features/data_sharing/services/hierarchical_import_planner.dart';

void main() {
  test('orders parents before children', () {
    final plan = planHierarchicalImport(
      items: const [
        _Folder('child', 'parent'),
        _Folder('parent', 'root'),
      ],
      idOf: (folder) => folder.id,
      parentIdOf: (folder) => folder.parentId,
      isRootParent: (parentId) => parentId == 'root',
      resourceLabel: 'folder',
    );

    expect(plan.orderedItems.map((folder) => folder.id), ['parent', 'child']);
    expect(plan.detachedIds, isEmpty);
  });

  test('marks folders with missing parents for root import', () {
    final plan = planHierarchicalImport(
      items: const [_Folder('child', 'missing')],
      idOf: (folder) => folder.id,
      parentIdOf: (folder) => folder.parentId,
      isRootParent: (parentId) => parentId == 'root',
      resourceLabel: 'folder',
    );

    expect(plan.orderedItems.single.id, 'child');
    expect(plan.detachedIds, {'child'});
  });

  test('rejects cycles instead of looping forever', () {
    expect(
      () => planHierarchicalImport(
        items: const [
          _Folder('one', 'two'),
          _Folder('two', 'one'),
        ],
        idOf: (folder) => folder.id,
        parentIdOf: (folder) => folder.parentId,
        isRootParent: (parentId) => parentId == 'root',
        resourceLabel: 'folder',
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('Cyclic folder hierarchy'),
        ),
      ),
    );
  });
}

class _Folder {
  const _Folder(this.id, this.parentId);

  final String id;
  final String parentId;
}
