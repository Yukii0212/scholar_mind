import '../datasources/assessment_firestore_datasource.dart';
import '../models/assessment_entry_model.dart';

class AssessmentRepository {
  const AssessmentRepository(
      this._datasource,
      );

  final AssessmentFirestoreDataSource
  _datasource;

  Stream<List<AssessmentEntryModel>>
  watchEntries(
      String courseId,
      ) {
    return _datasource.watchEntries(
      courseId,
    );
  }

  Future<void> saveEntry(
      AssessmentEntryModel entry,
      ) {
    return _datasource.saveEntry(
      entry,
    );
  }

  Future<List<AssessmentEntryModel>> getEntries(
      String courseId,
      ) {
    return _datasource.getEntries(
      courseId,
    );
  }

  Future<void> importEntry(
      AssessmentEntryModel entry,
      ) {
    return _datasource.importEntry(
      entry,
    );
  }

  Future<void> deleteEntry(
      String courseId,
      String id,
      ) {
    return _datasource.deleteEntry(
      courseId,
      id,
    );
  }
}