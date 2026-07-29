import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../domain/note_item.dart';

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

  // Each note gets its own subdirectory, named from its (immutable)
  // storagePath, so the cached file itself can keep a clean, human-readable
  // name — this is what external apps show as the file/window title when
  // opening it, and it must stay in sync with the note's current display
  // name rather than leaking internal storage-path plumbing into it.
  static Future<Directory> _noteCacheDirectory(
      String storagePath,
      ) async {
    final directory =
    await _cacheDirectory();

    final safeStorage =
    storagePath.replaceAll('/', '_');

    final noteDirectory = Directory(
      path.join(
        directory.path,
        safeStorage,
      ),
    );

    if (!noteDirectory.existsSync()) {
      noteDirectory.createSync(
        recursive: true,
      );
    }

    return noteDirectory;
  }

  static Future<File> _cacheFile(
      String storagePath,
      String fileName,
      ) async {
    final noteDirectory =
    await _noteCacheDirectory(storagePath);

    return File(
      path.join(
        noteDirectory.path,
        fileName,
      ),
    );
  }

  /// Renames a note's cached file in place (no re-download) so a rename
  /// stays immediately reflected locally instead of orphaning the old
  /// cache entry until the next background sync re-fetches it under the
  /// new name.
  static Future<void> renameCachedFile({
    required String storagePath,
    required String oldFileName,
    required String newFileName,
  }) async {
    if (oldFileName == newFileName) return;

    final oldFile = await _cacheFile(storagePath, oldFileName);

    if (!await oldFile.exists()) return;

    final newFile = await _cacheFile(storagePath, newFileName);

    if (await newFile.exists()) {
      await newFile.delete();
    }

    await oldFile.rename(newFile.path);
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
        note.displayFileName,
      );

      if (cached) {
        continue;
      }

      try {
        await downloadFromFirebase(
          storagePath: note.storagePath,
          fileName: note.displayFileName,
        );
      } catch (_) {
      }
    }
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
      note.displayFileName,
    );

    if (cached) {
      return;
    }

    await downloadFromFirebase(
      storagePath: note.storagePath,
      fileName: note.displayFileName,
    );
  }

  static Future<void> deleteCache(
      NoteItem note,
      ) async {
    await delete(
      storagePath: note.storagePath,
      fileName: note.displayFileName,
    );
  }
}