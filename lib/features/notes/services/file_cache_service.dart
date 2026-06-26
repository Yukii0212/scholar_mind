import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../domain/note_item.dart';
import '../../../core/services/background_sync_service.dart';

class FileCacheService {
  static const cacheDeletionDelay = Duration(
    seconds: 5,
  );

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

  static Future<void> syncMissingCaches(
      Iterable<NoteItem> notes,
      ) async {
    for (final note in notes) {
      if (note.isInternal) {
        continue;
      }

      if (note.storagePath.isEmpty) {
        continue;
      }

      final cached = await exists(
        note.storagePath,
        note.name,
      );

      if (cached) {
        continue;
      }

      try {
        await downloadFromFirebase(
          storagePath: note.storagePath,
          fileName: note.name,
        );
      } catch (_) {
      }
    }

    print('CACHE SYNC START');
    print('Notes: ${notes.length}');
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

  static Future<void> ensureCacheExists(
      NoteItem note,
      ) async {
    final cached = await exists(
      note.storagePath,
      note.name,
    );

    if (cached) {
      return;
    }

    await downloadFromFirebase(
      storagePath: note.storagePath,
      fileName: note.name,
    );
  }

  static Future<void> deleteCache(
      NoteItem note,
      ) async {
    print("DELETE FILE CALLED");
    await delete(
      storagePath: note.storagePath,
      fileName: note.name,
    );
  }
}