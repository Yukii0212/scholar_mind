import 'package:flutter_riverpod/flutter_riverpod.dart';

/// While `true`, the Notes screen's add-menu (the bottom-right speed-dial
/// FAB with "Import File" / "New Note" / "New Folder") is forced open, so
/// the "Adding notes and folders" tutorial
/// (`lib/features/notes/help/notes_library_help_topics.dart`) can spotlight
/// each option in turn instead of only ever describing the closed button.
/// Set by each tutorial step's `beforeShow` and cleared when the tutorial
/// closes. `NotesScreen` watches this and mirrors it into the local
/// `ValueNotifier` the `flutter_speed_dial` package needs to be told to
/// open/close programmatically.
final notesFabOpenProvider = StateProvider<bool>((ref) => false);
