import 'package:cloud_firestore/cloud_firestore.dart';

class SemesterFirestoreDataSource {
  SemesterFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('semesters');
  }
}
