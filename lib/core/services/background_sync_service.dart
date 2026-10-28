import 'dart:async';

import '../../features/notes/domain/note_item.dart';
import '../../features/notes/services/file_cache_service.dart';
import 'resource_manager.dart';

class BackgroundSyncService {
  StreamSubscription<List<NoteItem>>? _subscription;

  bool _started = false;
  bool _isCleaning = false;
  int _sessionRevision = 0;
  String? _sessionUserId;
  Timer? _cleanupTimer;

  final Map<String, NoteItem> _knownNotes = {};

  void start({
    required String userId,
    required Stream<List<NoteItem>> notesStream,
  }) {
    if (_started) return;

    _started = true;
    _sessionUserId = userId;
    final sessionRevision = ++_sessionRevision;

    _subscription = notesStream.listen(
      (notes) {
        if (!_isCurrentSession(sessionRevision, userId)) {
          return;
        }

        _handleSnapshot(notes);
      },
    );

    _cleanupTimer = Timer.periodic(
      FileCacheService.cacheDeletionDelay,
      (_) {
        if (!_isCurrentSession(sessionRevision, userId) || _isCleaning) {
          return;
        }

        unawaited(
          _cleanupExpiredCaches(
            sessionRevision: sessionRevision,
            userId: userId,
          ),
        );
      },
    );
  }

  Future<void> stop() async {
    _started = false;
    _sessionRevision++;
    _sessionUserId = null;

    _cleanupTimer?.cancel();
    _cleanupTimer = null;

    final subscription = _subscription;
    _subscription = null;

    await subscription?.cancel();

    _isCleaning = false;

    _knownNotes.clear();
  }

  bool _isCurrentSession(int sessionRevision, String userId) {
    return _started &&
        _sessionRevision == sessionRevision &&
        _sessionUserId == userId;
  }

  void _handleSnapshot(List<NoteItem> notes) {
    final currentIds = notes.map((note) => note.id).toSet();

    _knownNotes.removeWhere(
      (id, _) => !currentIds.contains(id),
    );

    for (final note in notes) {
      _knownNotes[note.id] = note;
    }
  }

  Future<void> _cleanupExpiredCaches({
    required int sessionRevision,
    required String userId,
  }) async {
    _isCleaning = true;

    try {
      final now = DateTime.now();

      for (final note in List<NoteItem>.of(_knownNotes.values)) {
        if (!_isCurrentSession(sessionRevision, userId)) {
          return;
        }

        if (!note.isDeleted) {
          continue;
        }

        if (note.isInternal || note.storagePath.trim().isEmpty) {
          continue;
        }

        if (note.cacheExpiresAt == null) {
          continue;
        }

        if (now.isBefore(note.cacheExpiresAt!)) {
          continue;
        }

        if (ResourceManager.isOpened(note.id)) {
          continue;
        }

        final exists = await FileCacheService.exists(
          note.storagePath,
          note.displayFileName,
        );

        if (!_isCurrentSession(sessionRevision, userId)) {
          return;
        }

        if (!exists) {
          continue;
        }

        await FileCacheService.deleteCache(note);
      }
    } finally {
      if (_isCurrentSession(sessionRevision, userId)) {
        _isCleaning = false;
      }
    }
  }
}
