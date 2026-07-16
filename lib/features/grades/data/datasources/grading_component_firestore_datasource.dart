import 'package:cloud_firestore/cloud_firestore.dart';

class GradingComponentFirestoreDataSource {
  GradingComponentFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore =
      firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
  get collection =>
      _firestore.collection(
        'grading_components',
      );
}