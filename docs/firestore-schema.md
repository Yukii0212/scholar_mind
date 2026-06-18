# Firestore schema

ScholarMind stores all private data below the authenticated user's document.
This makes ownership checks, deletion, and security rules predictable.

```text
users/{uid}
  folders/{folderId}
  notes/{noteId}
  courses/{courseId}
    flashcards/{flashcardId}
    assessments/{assessmentId}
    quizzes/{quizId}
  reviews/{reviewId}
```

Files use the matching Storage path:

```text
users/{uid}/notes/{noteId}/{fileName}
```

## Query rules

- Query only inside the signed-in user's path.
- Root-level folders and files use `folderId` or `parentId` equal to `__root__`.
- Folder nesting uses `folders.parentId`; archiving a folder hides its subtree
  without rewriting every descendant.
- Use Firestore-generated document IDs; keep a human-readable course code as data.
- Store timestamps as Firestore `Timestamp` values.
- Denormalize only fields required to render a list without extra reads.
- Add composite indexes only when a real application query requires them.
- Keep reviews under the user so the due-card query can span all courses.
- Imported notes use `source: classroom` plus the original Classroom IDs so
  duplicate imports can be detected later.

Feature-specific field validation belongs in `firestore.rules` when each model
is implemented. The current recursive rule establishes ownership isolation but
does not replace that validation.
