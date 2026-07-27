import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/grading_component_firestore_datasource.dart';
import '../models/grading_component_model.dart';

class GradingComponentRepository {
  GradingComponentRepository(
      this._dataSource,
      );

  final GradingComponentFirestoreDataSource
  _dataSource;

  Stream<List<GradingComponentModel>>
  watchCourseComponents(
      String courseId,
      ) {
    return _dataSource.collection
        .where(
      'courseId',
      isEqualTo: courseId,
    )
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
        GradingComponentModel
            .fromFirestore,
      )
          .toList(),
    );
  }

  Future<void> createComponent(
      GradingComponentModel component,
      ) async {
    final owned = component.copyWith(
      ownerId: _dataSource.currentUserId,
    );

    await _dataSource.collection
        .doc(owned.id)
        .set(
      owned.toFirestore(),
    );
  }

  Future<void> updateComponent(
      GradingComponentModel component,
      ) async {
    await _dataSource.collection
        .doc(component.id)
        .update(
      component
          .copyWith(
        updatedAt:
        DateTime.now(),
      )
          .toFirestore(),
    );
  }

  Future<void> deleteComponent(
      String componentId,
      ) async {
    await _dataSource.collection
        .doc(componentId)
        .delete();
  }

  Future<void> replaceCourseComponents({
    required String courseId,
    required List<GradingComponentModel>
    components,
  }) async {
    final ownerId = _dataSource.currentUserId;

    final batch =
    _dataSource.collection.firestore
        .batch();

    final existing =
    await _dataSource.collection
        .where(
      'courseId',
      isEqualTo: courseId,
    )
        .get();

    for (final doc
    in existing.docs) {
      batch.delete(doc.reference);
    }

    for (final component
    in components) {
      batch.set(
        _dataSource.collection.doc(
          component.id,
        ),
        component
            .copyWith(ownerId: ownerId)
            .toFirestore(),
      );
    }

    await batch.commit();
  }

  Future<List<GradingComponentModel>>
  getCourseComponents(
      String courseId,
      ) async {
    final snapshot =
    await _dataSource.collection
        .where(
      'courseId',
      isEqualTo: courseId,
    )
        .orderBy('order')
        .get();

    return snapshot.docs
        .map(
      GradingComponentModel
          .fromFirestore,
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
  }) async {
    final snapshot = await _dataSource.collection
        .where('courseId', isEqualTo: courseId)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      if ((data['ownerId'] as String?)?.isNotEmpty ?? false) {
        continue;
      }

      await doc.reference.set(
        {'ownerId': userId},
        SetOptions(merge: true),
      );
    }
  }
}
