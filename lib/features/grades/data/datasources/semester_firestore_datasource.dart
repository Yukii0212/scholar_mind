import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SemesterFirestoreDataSource {
  SemesterFirestoreDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('semesters');
  }

  CollectionReference<Map<String, dynamic>> get collection =>
      _collection;
}