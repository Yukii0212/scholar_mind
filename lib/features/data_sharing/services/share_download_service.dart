import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';

class ShareDownloadService {
  const ShareDownloadService();

  Future<Map<String, dynamic>> downloadArchive(
      String storagePath,
      ) async {
    final json = await FirebaseStorage.instance
        .ref(storagePath)
        .getData();

    if (json == null) {
      throw Exception(
        'Archive download failed.',
      );
    }

    final decoded = utf8.decode(json);

    return jsonDecode(decoded)
    as Map<String, dynamic>;
  }
}