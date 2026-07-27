import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../domain/models/share/share_expiry.dart';
import '../domain/models/share/share_result.dart';

class ShareLinkService {
  const ShareLinkService();

  Future<ShareResult> createLink({
    required String ownerId,
    required String storagePath,
    required ShareExpiry expiry,
  }) async {
    final document = FirebaseFirestore.instance
        .collection('export_links')
        .doc();

    final expiresAt =
    expiry.calculateExpiry();

    await document.set({
      'ownerId': ownerId,
      'storagePath': storagePath,
      'createdAt':
      FieldValue.serverTimestamp(),
      'expiresAt': expiresAt,
      'downloadCount': 0,
      'isRevoked': false,
    });

    final url = Uri.parse(
      'https://scholarmind.app/share/${document.id}',
    );

    return ShareResult(
      shareId: document.id,
      shareUrl: url,
      storagePath: storagePath,
      expiresAt: expiresAt,
    );
  }
}