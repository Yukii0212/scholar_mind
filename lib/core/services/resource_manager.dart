class ResourceManager {
  ResourceManager._();

  static final Set<String> _openedNotes = {};

  static void markOpened(
      String noteId,
      ) {
    _openedNotes.add(noteId);
  }

  static void markClosed(
      String noteId,
      ) {
    _openedNotes.remove(noteId);
  }

  static bool isOpened(
      String noteId,
      ) {
    return _openedNotes.contains(noteId);
  }
}