# Firestore schema

ScholarMind stores all private data below the authenticated user's document.
This makes ownership checks, deletion, and security rules predictable.

```text
users/{uid}
  courses/{courseId}
    notes/{noteId}
    flashcards/{flashcardId}
    assessments/{assessmentId}
    quizzes/{quizId}
  reviews/{reviewId}
```

Files use the matching Storage path:

```text
users/{uid}/courses/{courseId}/notes/{noteId}/{fileName}
```

## Query rules

- Query only inside the signed-in user's path.
- Use Firestore-generated document IDs; keep a human-readable course code as data.
- Store timestamps as Firestore `Timestamp` values.
- Denormalize only fields required to render a list without extra reads.
- Add composite indexes only when a real application query requires them.
- Keep reviews under the user so the due-card query can span all courses.

Feature-specific field validation belongs in `firestore.rules` when each model
is implemented. The current recursive rule establishes ownership isolation but
does not replace that validation.
