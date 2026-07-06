import 'quiz_attempt.dart';

class QuizLibraryItem {
  const QuizLibraryItem({
    required this.attempt,
    required this.title,
    required this.createdAt,
    required this.lastOpenedAt,
    required this.lastModifiedAt,
  });

  final QuizAttempt attempt;

  final String title;

  final DateTime createdAt;

  final DateTime lastOpenedAt;

  final DateTime lastModifiedAt;

  QuizLibraryItem copyWith({
    QuizAttempt? attempt,
    String? title,
    DateTime? createdAt,
    DateTime? lastOpenedAt,
    DateTime? lastModifiedAt,
  }) {
    return QuizLibraryItem(
      attempt: attempt ?? this.attempt,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastOpenedAt:
      lastOpenedAt ?? this.lastOpenedAt,
      lastModifiedAt:
      lastModifiedAt ??
          this.lastModifiedAt,
    );
  }
}