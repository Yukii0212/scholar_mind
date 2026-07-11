import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/assessment_entry_model.dart';

class AssessmentFirestoreDataSource {
  AssessmentFirestoreDataSource(
      FirebaseFirestore firestore,
      ) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
  _collection(
      String courseId,
      ) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection(
      'assessmentEntries',
    );
  }

  Stream<List<AssessmentEntryModel>>
  watchEntries(
      String courseId,
      ) {
    return _collection(courseId)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
        AssessmentEntryModel
            .fromFirestore,
      )
          .toList(),
    );
  }

  Future<void> saveEntry(
      AssessmentEntryModel entry,
      ) async {
    await _collection(
      entry.courseId,
    ).doc(entry.id).set(
      entry.toFirestore(),
    );
  }

  Future<void> deleteEntry(
      String courseId,
      String entryId,
      ) async {
    await _collection(
      courseId,
    ).doc(entryId).delete();
  }
}