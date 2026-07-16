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
    await _dataSource.collection
        .doc(component.id)
        .set(
      component.toFirestore(),
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
        component.toFirestore(),
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
}