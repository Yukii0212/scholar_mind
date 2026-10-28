import 'dart:convert';
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

  static Directory? _cacheDirectoryOverride;

  static void setCacheDirectoryForTesting(Directory? directory) {
    _cacheDirectoryOverride = directory;
  }

  static Future<Directory> _cacheDirectory() async {
    final override = _cacheDirectoryOverride;

    if (override != null) {
      if (!await override.exists()) {
        await override.create(recursive: true);
      }

      return override;
    }

    final supportDir = await getApplicationSupportDirectory();

    final directory = Directory(
      path.join(
        supportDir.path,
        'cache',
        'notes',
      ),
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
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
    if (storagePath.isEmpty) {
      throw ArgumentError.value(
        storagePath,
        'storagePath',
        'Storage path cannot be empty.',
      );
    }

    final directory = await _cacheDirectory();
    final ownerId = _ownerId(storagePath);
    var directoryPath = path.join(
      directory.path,
      'v2',
      _encodePathComponent(ownerId),
    );

    for (final component in _encodedPathComponents(storagePath)) {
      directoryPath = path.join(directoryPath, component);
    }

    final noteDirectory = Directory(directoryPath);

    if (!await noteDirectory.exists()) {
      await noteDirectory.create(recursive: true);
    }

    return noteDirectory;
  }

  static Future<File> _cacheFile(
    String storagePath,
    String fileName,
  ) async {
    final noteDirectory = await _noteCacheDirectory(storagePath);
    final safeFileName = _safeFileName(fileName);
    final candidatePath = path.normalize(
      path.absolute(
        path.join(noteDirectory.path, safeFileName),
      ),
    );
    final noteDirectoryPath = path.normalize(
      path.absolute(noteDirectory.path),
    );

    if (!path.isWithin(noteDirectoryPath, candidatePath)) {
      throw ArgumentError.value(
        fileName,
        'fileName',
        'Cache filename must stay within its note directory.',
      );
    }

    return File(candidatePath);
  }

  static String _ownerId(String storagePath) {
    final segments = storagePath
        .replaceAll('\\', '/')
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);

    if (segments.length >= 2 && segments.first == 'users') {
      return segments[1];
    }

    return '_unscoped';
  }

  static String _encodePathComponent(String value) {
    return base64Url.encode(utf8.encode(value));
  }

  static Iterable<String> _encodedPathComponents(String storagePath) sync* {
    final encoded = _encodePathComponent(storagePath);

    for (var offset = 0; offset < encoded.length; offset += 120) {
      final end = offset + 120 < encoded.length ? offset + 120 : encoded.length;
      yield encoded.substring(offset, end);
    }
  }

  static String _safeFileName(String fileName) {
    var safeName = fileName.replaceAll(RegExp(r'[/\\\x00-\x1F]'), '_');

    if (safeName.isEmpty || safeName == '.' || safeName == '..') {
      safeName = 'note';
    }

    return safeName;
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
    final ref = FirebaseStorage.instance.ref(
      storagePath,
    );

    final url = await ref.getDownloadURL();

    return downloadFromUrl(
      storagePath: storagePath,
      fileName: fileName,
      url: Uri.parse(url),
    );
  }

  static Future<File> downloadFromUrl({
    required String storagePath,
    required String fileName,
    required Uri url,
  }) async {
    final response = await http.get(url);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Note download failed with HTTP ${response.statusCode}.',
        uri: url,
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
      } catch (_) {}
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

  static Future<void> clearUserCache(String userId) async {
    if (userId.isEmpty) return;

    final cacheDirectory = await _cacheDirectory();
    final accountDirectory = Directory(
      path.join(
        cacheDirectory.path,
        'v2',
        _encodePathComponent(userId),
      ),
    );

    if (await accountDirectory.exists()) {
      await accountDirectory.delete(recursive: true);
    }

    final legacyPrefix = 'users_${userId}_notes_';

    await for (final entity in cacheDirectory.list()) {
      if (entity is! Directory) continue;

      final entityName = path.basename(entity.path);
      if (entityName.startsWith(legacyPrefix)) {
        await entity.delete(recursive: true);
      }
    }
  }
}
