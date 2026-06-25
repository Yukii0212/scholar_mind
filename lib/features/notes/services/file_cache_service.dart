import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileCacheService {
  FileCacheService._();

  static Future<Directory> _cacheDirectory() async {
    final supportDir =
    await getApplicationSupportDirectory();

    final directory = Directory(
      path.join(
        supportDir.path,
        'cache',
        'notes',
      ),
    );

    if (!directory.existsSync()) {
      directory.createSync(
        recursive: true,
      );
    }

    return directory;
  }

  static Future<File> _cacheFile(
      String storagePath,
      String fileName,
      ) async {
    final directory =
    await _cacheDirectory();

    final safeStorage =
    storagePath.replaceAll('/', '_');

    return File(
      path.join(
        directory.path,
        '${safeStorage}_$fileName',
      ),
    );
  }

  static Future<bool> exists(
      String storagePath,
      String fileName,
      ) async {
    final file = await _cacheFile(
      storagePath,
      fileName,
    );

    return file.exists();
  }

  static Future<File> saveBytes({
    required String storagePath,
    required String fileName,
    required List<int> bytes,
  }) async {
    final file = await _cacheFile(
      storagePath,
      fileName,
    );

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    return file;
  }

  static Future<File> getFile({
    required String storagePath,
    required String fileName,
  }) async {
    return _cacheFile(
      storagePath,
      fileName,
    );
  }

  static Future<File> downloadFromFirebase({
    required String storagePath,
    required String fileName,
  }) async {
    final ref =
    FirebaseStorage.instance.ref(
      storagePath,
    );

    final url =
    await ref.getDownloadURL();

    final response =
    await http.get(
      Uri.parse(url),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to download cached file.',
      );
    }

    return saveBytes(
      storagePath: storagePath,
      fileName: fileName,
      bytes: response.bodyBytes,
    );
  }

  static Future<void> delete({
    required String storagePath,
    required String fileName,
  }) async {
    final file = await _cacheFile(
      storagePath,
      fileName,
    );

    if (await file.exists()) {
      await file.delete();
    }
  }
}