import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/library_enums.dart';

/// Set by the "Library, Favorites, Archived & Trash" tutorial
/// (`lib/features/notes/help/notes_library_help_topics.dart`) to switch
/// the Notes screen to whichever section the current step is describing,
/// so the view underneath actually matches the narration instead of
/// staying on Library the whole time. `NotesScreen` watches this and
/// applies it to its own local `_section` state. Null means "no override
/// pending" -- it's reset to null implicitly by the tutorial always
/// setting a fresh value per step, and explicitly back to Library when
/// the tutorial closes.
final notesSectionOverrideProvider = StateProvider<LibrarySection?>(
  (ref) => null,
);
