import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/course_firestore_datasource.dart';
import '../models/course_model.dart';
import 'grading_component_repository.dart';

class CourseRepository {
  CourseRepository(
      this._dataSource,
      );

  final CourseFirestoreDataSource _dataSource;

  Stream<List<CourseModel>> watchCourses(
      String userId,
      ) {
    return _dataSource.collection
        .where(
      'ownerId',
      isEqualTo: userId,
    )
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(CourseModel.fromFirestore)
          .toList(),
    );
  }

  Stream<List<CourseModel>> watchSemesterCourses({
    required String userId,
    required String semesterId,
  }) {
    return _dataSource.collection
        .where(
      'ownerId',
      isEqualTo: userId,
    )
        .where(
      'semesterId',
      isEqualTo: semesterId,
    )
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(CourseModel.fromFirestore)
          .toList(),
    );
  }

  Stream<CourseModel> watchCourse(
      String courseId,
      ) {
    return _dataSource.collection
        .doc(courseId)
        .snapshots()
        .map(
          (snapshot) =>
          CourseModel.fromFirestore(
            snapshot,
          ),
    );
  }

  Future<void> createCourse(
      CourseModel course,
      ) async {
    final owned = course.copyWith(
      ownerId: _dataSource.currentUserId,
    );

    await _dataSource.collection
        .doc(owned.id)
        .set(
      owned.toFirestore(),
    );
  }

  Future<CourseModel?> getCourse(
      String courseId,
      ) async {
    final snapshot =
    await _dataSource.collection.doc(courseId).get();

    if (!snapshot.exists) return null;

    return CourseModel.fromFirestore(snapshot);
  }

  Future<List<CourseModel>> getSemesterCourses({
    required String userId,
    required String semesterId,
  }) async {
    final snapshot = await _dataSource.collection
        .where(
      'ownerId',
      isEqualTo: userId,
    )
        .where(
      'semesterId',
      isEqualTo: semesterId,
    )
        .get();

    return snapshot.docs
        .map(CourseModel.fromFirestore)
        .toList();
  }

  Future<String> importCourse({
    required CourseModel course,
    required String ownerId,
    required String semesterId,
  }) async {
    final now = DateTime.now();
    final reference = _dataSource.collection.doc();

    final imported = CourseModel(
      id: reference.id,
      ownerId: ownerId,
      semesterId: semesterId,
      name: course.name,
      targetScore: course.targetScore,
      minimumAcceptableScore: course.minimumAcceptableScore,
      passingScore: course.passingScore,
      createdAt: now,
      updatedAt: now,
    );

    await reference.set(
      imported.toFirestore(),
    );

    return reference.id;
  }

  Future<void> updateCourse(
      CourseModel course,
      ) async {
    await _dataSource.collection
        .doc(course.id)
        .update(
      course.copyWith(
        updatedAt: DateTime.now(),
      ).toFirestore(),
    );
  }

  Future<void> deleteCourse(
      String courseId,
      ) async {
    await _dataSource.collection
        .doc(courseId)
        .delete();
  }

  Future<CourseModel> copyCourse({
    required CourseModel source,
    required String semesterId,
  }) async {
    final now = DateTime.now();

    final copiedCourse = CourseModel(
      id: _dataSource.collection.doc().id,
      ownerId: _dataSource.currentUserId,
      semesterId: semesterId,

      name: source.name,

      targetScore:
      source.targetScore,

      minimumAcceptableScore:
      source.minimumAcceptableScore,

      passingScore:
      source.passingScore,

      createdAt: now,
      updatedAt: now,
    );

    await createCourse(
      copiedCourse,
    );

    return copiedCourse;
  }

  /// One-time backfill for courses/grading components created before
  /// ownership tracking was added. Traces ownership via the user's own
  /// (properly user-scoped) semesters -> courses -> grading components,
  /// since there's no other signal available on the older documents.
  /// Safe to call repeatedly; only touches documents missing ownerId.
  Future<void> backfillOwnership({
    required String userId,
    required List<String> semesterIds,
    required GradingComponentRepository componentRepository,
  }) async {
    if (semesterIds.isEmpty) return;

    for (final batch in _chunks(semesterIds, 30)) {
      final snapshot = await _dataSource.collection
          .where('semesterId', whereIn: batch)
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

        await componentRepository.backfillOwnership(
          userId: userId,
          courseId: doc.id,
        );
      }
    }
  }

  static Iterable<List<T>> _chunks<T>(List<T> items, int size) sync* {
    for (var i = 0; i < items.length; i += size) {
      yield items.sublist(
        i,
        i + size > items.length ? items.length : i + size,
      );
    }
  }
}
