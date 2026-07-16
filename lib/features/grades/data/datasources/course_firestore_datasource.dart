import 'package:cloud_firestore/cloud_firestore.dart';

class CourseFirestoreDataSource {
  CourseFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore =
      firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
  get collection => _firestore.collection(
    'courses',
  );
}