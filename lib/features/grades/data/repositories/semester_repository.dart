import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/semester_firestore_datasource.dart';
import '../models/semester_model.dart';

class SemesterRepository {
  SemesterRepository({
    SemesterFirestoreDataSource? dataSource,
  }) : _dataSource =
      dataSource ?? SemesterFirestoreDataSource();

  final SemesterFirestoreDataSource _dataSource;

  Stream<List<SemesterModel>> watchSemesters() {
    return _dataSource.collection
        .orderBy('startDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(SemesterModel.fromFirestore)
          .toList(),
    );
  }

  Future<bool> hasOverlappingSemester({
    required DateTime startDate,
    required DateTime endDate,
    String? excludeSemesterId,
  }) async {
    final snapshot = await _dataSource.collection.get();

    final semesters = snapshot.docs
        .map(SemesterModel.fromFirestore);

    for (final semester in semesters) {
      if (excludeSemesterId != null &&
          semester.id == excludeSemesterId) {
        continue;
      }

      final overlaps =
          startDate.isBefore(semester.endDate) &&
              endDate.isAfter(semester.startDate);

      if (overlaps) {
        return true;
      }
    }

    return false;
  }

  Future<void> createSemester(
      SemesterModel semester,
      ) async {
    final doc = _dataSource.collection.doc();

    await doc.set(
      semester.copyWith(
        id: doc.id,
      ).toFirestore(),
    );
  }

  Future<void> updateSemester(
      SemesterModel semester,
      ) async {
    await _dataSource.collection
        .doc(semester.id)
        .update(semester.toFirestore());
  }

  Future<void> toggleHidden({
    required String semesterId,
    required bool isHidden,
  }) async {
    await _dataSource.collection
        .doc(semesterId)
        .update({
      'isHidden': isHidden,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteSemester(
      String semesterId,
      ) async {
    await _dataSource.collection
        .doc(semesterId)
        .delete();
  }
}