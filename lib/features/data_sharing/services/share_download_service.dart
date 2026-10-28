import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';

import 'share_download_limits.dart';

class ShareDownloadService {
  const ShareDownloadService();

  Future<Map<String, dynamic>> downloadArchive(
    String storagePath,
  ) async {
    final json = await FirebaseStorage.instance
        .ref(storagePath)
        .getData(maxShareObjectDownloadBytes);

    if (json == null) {
      throw Exception(
        'Archive download failed.',
      );
    }

    try {
      final decoded = utf8.decode(json);
      final archive = jsonDecode(decoded);

      if (archive is! Map) {
        throw const FormatException(
          'Downloaded share archive must be a JSON object.',
        );
      }

      return Map<String, dynamic>.from(archive);
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException('Downloaded share archive is invalid: $error');
    }
  }
}
