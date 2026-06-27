import 'dart:async';

import '../../features/notes/domain/note_item.dart';
import '../../features/notes/services/file_cache_service.dart';
import 'resource_manager.dart';

class BackgroundSyncService {
  StreamSubscription<List<NoteItem>>? _subscription;

  bool _started = false;
  Timer? _cleanupTimer;

  final Map<String, NoteItem> _knownNotes = {};

  void start(
      Stream<List<NoteItem>> notesStream,
      ) {
    if (_started) return;

    _started = true;

    _subscription = notesStream.listen(
      _handleSnapshot,
    );

    _cleanupTimer = Timer.periodic(
      FileCacheService.cacheDeletionDelay,
          (_) => _cleanupExpiredCaches(),
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();

    _cleanupTimer?.cancel();

    _subscription = null;
    _cleanupTimer = null;

    _knownNotes.clear();

    _started = false;
  }
  Future<void> _handleSnapshot(
      List<NoteItem> notes,
      ) async {

    final currentIds = notes
        .map(
          (note) => note.id,
    )
        .toSet();

    _knownNotes.removeWhere(
          (id, _) => !currentIds.contains(id),
    );

    for (final note in notes) {

      _knownNotes[note.id] = note;

      if (
      !note.isDeleted &&
          !note.isInternal &&
          note.storagePath.isNotEmpty
      ) {
        await FileCacheService.ensureCacheExists(
          note,
        );
      }
    }
  }

  Future<void> _cleanupExpiredCaches() async {

    final now = DateTime.now();

    for (final note in _knownNotes.values) {

      if (!note.isDeleted) {
        continue;
      }

      if (note.cacheExpiresAt == null) {
        continue;
      }

      if (
      now.isBefore(
        note.cacheExpiresAt!,
      )
      ) {
        continue;
      }

      if (
      ResourceManager.isOpened(
        note.id,
      )
      ) {
        continue;
      }

      final exists =
      await FileCacheService.exists(
        note.storagePath,
        note.name,
      );

      if (!exists) {
        continue;
      }

      await FileCacheService.deleteCache(
        note,
      );
    }
  }
}