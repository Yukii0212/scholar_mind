import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/course_firestore_datasource.dart';
import '../models/course_model.dart';

class CourseRepository {
  CourseRepository(
      this._dataSource,
      );

  final CourseFirestoreDataSource _dataSource;

  Stream<List<CourseModel>> watchCourses() {
    return _dataSource.collection
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(CourseModel.fromFirestore)
          .toList(),
    );
  }

  Stream<List<CourseModel>> watchSemesterCourses(
      String semesterId,
      ) {
    return _dataSource.collection
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

  Stream<List<CourseModel>> watchPersonalCourses() {
    return _dataSource.collection
        .where(
      'semesterId',
      isNull: true,
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
    await _dataSource.collection
        .doc(course.id)
        .set(
      course.toFirestore(),
    );
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
    required String? semesterId,
  }) async {
    final now = DateTime.now();

    final copiedCourse = CourseModel(
      id: _dataSource.collection.doc().id,
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
}