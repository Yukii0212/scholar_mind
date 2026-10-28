import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/grading_component_firestore_datasource.dart';
import '../models/grading_component_model.dart';

class GradingComponentRepository {
  static const _batchWriteLimit = 450;

  GradingComponentRepository(
    this._dataSource,
  );

  final GradingComponentFirestoreDataSource _dataSource;

  Stream<List<GradingComponentModel>> watchCourseComponents(
    String userId,
    String courseId,
  ) {
    return _dataSource.collection
        .where(
          'ownerId',
          isEqualTo: userId,
        )
        .where(
          'courseId',
          isEqualTo: courseId,
        )
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                GradingComponentModel.fromFirestore,
              )
              .toList(),
        );
  }

  Future<void> createComponent({
    required String userId,
    required GradingComponentModel component,
  }) async {
    final owned = component.copyWith(
      ownerId: userId,
    );

    await _dataSource.collection.doc(owned.id).set(
          owned.toFirestore(),
        );
  }

  Future<void> updateComponent(
    GradingComponentModel component,
  ) async {
    await _dataSource.collection.doc(component.id).update(
          component
              .copyWith(
                updatedAt: DateTime.now(),
              )
              .toFirestore(),
        );
  }

  Future<void> deleteComponent(
    String componentId,
  ) async {
    await _dataSource.collection.doc(componentId).delete();
  }

  Future<void> replaceCourseComponents({
    required String userId,
    required String courseId,
    required List<GradingComponentModel> components,
  }) async {
    final existing = await _dataSource.collection
        .where(
          'ownerId',
          isEqualTo: userId,
        )
        .where(
          'courseId',
          isEqualTo: courseId,
        )
        .get();

    final writes = <void Function(WriteBatch)>[
      for (final doc in existing.docs) (batch) => batch.delete(doc.reference),
      for (final component in components)
        (batch) => batch.set(
              _dataSource.collection.doc(component.id),
              component.copyWith(ownerId: userId).toFirestore(),
            ),
    ];

    for (var start = 0; start < writes.length; start += _batchWriteLimit) {
      final end = start + _batchWriteLimit < writes.length
          ? start + _batchWriteLimit
          : writes.length;
      final batch = _dataSource.collection.firestore.batch();

      for (final write in writes.sublist(start, end)) {
        write(batch);
      }

      await batch.commit();
    }
  }

  Future<List<GradingComponentModel>> getCourseComponents(
    String userId,
    String courseId,
  ) async {
    final snapshot = await _dataSource.collection
        .where(
          'ownerId',
          isEqualTo: userId,
        )
        .where(
          'courseId',
          isEqualTo: courseId,
        )
        .orderBy('order')
        .get();

    return snapshot.docs
        .map(
          GradingComponentModel.fromFirestore,
        )
        .toList();
  }

  Future<String> importComponent({
    required GradingComponentModel component,
    required String ownerId,
    required String courseId,
    String? parentId,
  }) async {
    final now = DateTime.now();
    final reference = _dataSource.collection.doc();

    final imported = GradingComponentModel(
      id: reference.id,
      ownerId: ownerId,
      courseId: courseId,
      parentId: parentId,
      name: component.name,
      weight: component.weight,
      order: component.order,
      createdAt: now,
      updatedAt: now,
    );

    await reference.set(
      imported.toFirestore(),
    );

    return reference.id;
  }

  /// One-time backfill for grading components created before ownership
  /// tracking was added. Called from CourseRepository.backfillOwnership
  /// once a course's own ownerId has been resolved. Safe to call
  /// repeatedly; only touches documents missing ownerId.
  Future<void> backfillOwnership({
    required String userId,
    required String courseId,
    void Function()? ensureSessionCurrent,
  }) async {
    ensureSessionCurrent?.call();
    final snapshot = await _dataSource.collection
        .where('courseId', isEqualTo: courseId)
        .get();
    ensureSessionCurrent?.call();

    for (final doc in snapshot.docs) {
      ensureSessionCurrent?.call();
      final data = doc.data();

      if ((data['ownerId'] as String?)?.isNotEmpty ?? false) {
        continue;
      }

      await doc.reference.set(
        {'ownerId': userId},
        SetOptions(merge: true),
      );
      ensureSessionCurrent?.call();
    }
  }
}
