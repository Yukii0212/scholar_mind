import '../domain/models/share/share_resource.dart';
import '../domain/models/share/share_resource_type.dart';

// Resources a user would actually recognize as "things I selected" —
// child records that ride along with a container (individual flashcards
// under a deck, grading components/assessment entries under a course) are
// deliberately excluded so a summary reads as "1 flashcard deck" rather
// than the noisier and less meaningful "1 flashcard deck, 38 flashcards".
const _headlineTypes = {
  ShareResourceType.note,
  ShareResourceType.noteFolder,
  ShareResourceType.flashcardDeck,
  ShareResourceType.quiz,
  ShareResourceType.quizFolder,
  ShareResourceType.countdown,
  ShareResourceType.gradeSemester,
  ShareResourceType.gradeCourse,
};

/// Counts, keyed by [ShareResourceType.value], of the headline resource
/// types in an export — the shape persisted on an `export_links` doc as
/// `resourceCounts`, and read back to tell a user what a share link
/// actually contains without them having to open it first.
Map<String, int> summarizeResources(List<ShareResource> resources) {
  final counts = <String, int>{};

  for (final resource in resources) {
    if (!_headlineTypes.contains(resource.resourceType)) {
      continue;
    }

    final key = resource.resourceType.value;
    counts[key] = (counts[key] ?? 0) + 1;
  }

  return counts;
}

/// e.g. "12 notes, 2 folders" — a human-readable rendering of resource
/// counts keyed by type, shared by every place a share link's contents
/// need to be shown (the shared-links list, the QR/link view, the
/// just-generated result).
String describeResourceCounts(Map<ShareResourceType, int> counts) {
  if (counts.isEmpty) {
    return 'Shared materials';
  }

  return counts.entries
      .map((entry) => '${entry.value} ${entry.key.pluralLabel(entry.value)}')
      .join(', ');
}
