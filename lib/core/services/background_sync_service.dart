import 'dart:async';

import '../../features/notes/domain/note_item.dart';
import '../../features/notes/services/file_cache_service.dart';

class BackgroundSyncService {
  StreamSubscription<List<NoteItem>>? _subscription;

  bool _started = false;

  void start(
      Stream<List<NoteItem>> notesStream,
      ) {
    if (_started) return;

    _started = true;

    _subscription = notesStream.listen(
          (notes) {

        unawaited(
          FileCacheService.syncMissingCaches(notes),
        );
      },
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();

    _subscription = null;
    _started = false;
  }
}