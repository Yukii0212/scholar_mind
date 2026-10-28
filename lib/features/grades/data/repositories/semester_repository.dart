import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/semester_firestore_datasource.dart';
import '../models/semester_model.dart';

class SemesterRepository {
  SemesterRepository({
    SemesterFirestoreDataSource? dataSource,
  }) : _dataSource = dataSource ?? SemesterFirestoreDataSource();

  final SemesterFirestoreDataSource _dataSource;

  Stream<List<SemesterModel>> watchSemesters(String userId) {
    return _dataSource
        .collection(userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(SemesterModel.fromFirestore).toList(),
        );
  }

  Future<bool> hasOverlappingSemester({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeSemesterId,
  }) async {
    final snapshot = await _dataSource.collection(userId).get();

    final semesters = snapshot.docs.map(SemesterModel.fromFirestore);

    for (final semester in semesters) {
      if (excludeSemesterId != null && semester.id == excludeSemesterId) {
        continue;
      }

      final overlaps = startDate.isBefore(semester.endDate) &&
          endDate.isAfter(semester.startDate);

      if (overlaps) {
        return true;
      }
    }

    return false;
  }

  Future<SemesterModel?> getSemester(
    String userId,
    String semesterId,
  ) async {
    final snapshot = await _dataSource.collection(userId).doc(semesterId).get();

    if (!snapshot.exists) return null;

    return SemesterModel.fromFirestore(snapshot);
  }

  Future<void> createSemester(
    String userId,
    SemesterModel semester,
  ) async {
    final doc = _dataSource.collection(userId).doc();
    final data = semester
        .copyWith(
          id: doc.id,
        )
        .toFirestore();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await doc.set(data);
  }

  Future<String> importSemester(
    String userId,
    SemesterModel semester,
  ) async {
    final doc = _dataSource.collection(userId).doc();
    final data = semester
        .copyWith(
          id: doc.id,
          isCurrent: false,
          isManuallyEdited: false,
          isHidden: false,
        )
        .toFirestore();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await doc.set(data);

    return doc.id;
  }

  Future<void> updateSemester(
    String userId,
    SemesterModel semester,
  ) async {
    await _dataSource
        .collection(userId)
        .doc(semester.id)
        .update(semester.toFirestore());
  }

  Future<void> toggleHidden({
    required String userId,
    required String semesterId,
    required bool isHidden,
  }) async {
    await _dataSource.collection(userId).doc(semesterId).update({
      'isHidden': isHidden,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteSemester(
    String userId,
    String semesterId,
  ) async {
    await _dataSource.collection(userId).doc(semesterId).delete();
  }
}
