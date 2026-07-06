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

  Future<void> deleteSemester(
      String semesterId,
      ) async {
    await _dataSource.collection
        .doc(semesterId)
        .delete();
  }
}