import 'package:open_filex/open_filex.dart';

import '../domain/note_item.dart';
import 'file_cache_service.dart';

class FileOpenService {
  static Future<void> openUploadedFile(
      NoteItem note,
      ) async {

    if (note.isInternal) {
      return;
    }

    if (await FileCacheService.exists(
      note.storagePath,
      note.name,
    )) {

      final file =
      await FileCacheService.getFile(
        storagePath:
        note.storagePath,
        fileName:
        note.name,
      );

      await OpenFilex.open(
        file.path,
      );

      return;
    }

    final file =
    await FileCacheService
        .downloadFromFirebase(
      storagePath:
      note.storagePath,
      fileName:
      note.name,
    );

    await OpenFilex.open(
      file.path,
    );
  }
}