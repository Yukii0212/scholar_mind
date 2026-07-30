import 'package:cloud_firestore/cloud_firestore.dart';

class ShareLookupService {
  const ShareLookupService();

  static const _maxAttempts = 3;
  static const _retryDelay = Duration(seconds: 2);

  Future<DocumentSnapshot<Map<String, dynamic>>> lookup(
      String shareId,
      ) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await FirebaseFirestore.instance
            .collection('export_links')
            .doc(shareId)
            .get();
      } on FirebaseException catch (e) {
        // A fresh share link has nothing cached to fall back on, so a
        // transient outage otherwise surfaces immediately as a hard
        // failure — the error message itself says retrying with backoff
        // is exactly the right thing to do, so do that here rather than
        // relying on the user to notice and retry manually.
        if (e.code != 'unavailable' || attempt >= _maxAttempts) {
          rethrow;
        }

        await Future<void>.delayed(_retryDelay * attempt);
      }
    }
  }
}