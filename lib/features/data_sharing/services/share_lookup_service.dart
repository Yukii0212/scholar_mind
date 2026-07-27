import 'package:cloud_firestore/cloud_firestore.dart';

class ShareLookupService {
  const ShareLookupService();

  Future<DocumentSnapshot<Map<String, dynamic>>> lookup(
      String shareId,
      ) {
    return FirebaseFirestore.instance
        .collection('export_links')
        .doc(shareId)
        .get();
  }
}