import 'package:cloud_firestore/cloud_firestore.dart';

import 'flashcard_folder.dart';

enum FlashcardGenerationMethod {
  manual,
  aiGenerated;

  String get label => switch (this) {
        FlashcardGenerationMethod.manual => 'Manual',
        FlashcardGenerationMethod.aiGenerated => 'AI Generated',
      };

  static FlashcardGenerationMethod fromJson(String? value) {
    return FlashcardGenerationMethod.values.firstWhere(
      (method) => method.name == value,
      orElse: () => FlashcardGenerationMethod.manual,
    );
  }
}

class FlashcardSet {
  const FlashcardSet({
    required this.id,
    required this.name,
    required this.tags,
    required this.generationMethod,
    required this.sourceReference,
    required this.description,
    required this.cardCount,
    required this.sessionsCompleted,
    required this.cardsReviewed,
    required this.knownCards,
    required this.needsReviewCards,
    required this.folderId,
    required this.isDeleted,
    required this.deletedAt,
    required this.deletedAsCascade,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final List<String> tags;
  final FlashcardGenerationMethod generationMethod;
  final String? sourceReference;
  final String? description;
  final int cardCount;
  final int sessionsCompleted;
  final int cardsReviewed;
  final int knownCards;
  final int needsReviewCards;
  final String folderId;
  final bool isDeleted;
  final DateTime? deletedAt;

  // See FlashcardFolder.deletedAsCascade -- same meaning, same reason.
  final bool deletedAsCascade;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory FlashcardSet.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    return FlashcardSet(
      id: doc.id,
      name: data['name'] as String? ?? 'Untitled Set',
      tags: (data['tags'] as List<dynamic>? ?? const [])
          .map((tag) => tag.toString())
          .toList(),
      generationMethod: FlashcardGenerationMethod.fromJson(
        data['generationMethod'] as String?,
      ),
      sourceReference: data['sourceReference'] as String?,
      description: data['description'] as String?,
      cardCount: data['cardCount'] as int? ?? 0,
      sessionsCompleted: data['sessionsCompleted'] as int? ?? 0,
      cardsReviewed: data['cardsReviewed'] as int? ?? 0,
      knownCards: data['knownCards'] as int? ?? 0,
      needsReviewCards: data['needsReviewCards'] as int? ?? 0,
      folderId: data['folderId'] as String? ?? FlashcardFolder.rootId,
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedAt: data['deletedAt'] != null
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
      deletedAsCascade: data['deletedAsCascade'] as bool? ?? false,
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
    );
  }
}

class Flashcard {
  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.tags,
    required this.frontImageUrl,
    required this.backImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String front;
  final String back;
  final List<String> tags;
  final String? frontImageUrl;
  final String? backImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Flashcard.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    return Flashcard(
      id: doc.id,
      front: data['front'] as String? ?? '',
      back: data['back'] as String? ?? '',
      tags: (data['tags'] as List<dynamic>? ?? const [])
          .map((tag) => tag.toString())
          .toList(),
      frontImageUrl: data['frontImageUrl'] as String?,
      backImageUrl: data['backImageUrl'] as String?,
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
    );
  }
}

class GeneratedFlashcardSet {
  const GeneratedFlashcardSet({
    required this.title,
    required this.cards,
  });

  final String title;
  final List<GeneratedFlashcard> cards;

  factory GeneratedFlashcardSet.fromJson(Map<String, dynamic> json) {
    return GeneratedFlashcardSet(
      title: json['title'] as String? ?? 'Generated Flashcards',
      cards: (json['cards'] as List<dynamic>? ?? const [])
          .map(
            (card) => GeneratedFlashcard.fromJson(
              Map<String, dynamic>.from(card as Map),
            ),
          )
          .toList(),
    );
  }
}

class GeneratedFlashcard {
  const GeneratedFlashcard({
    required this.front,
    required this.back,
    required this.tags,
  });

  final String front;
  final String back;
  final List<String> tags;

  factory GeneratedFlashcard.fromJson(Map<String, dynamic> json) {
    return GeneratedFlashcard(
      front: json['front'] as String? ?? '',
      back: json['back'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((tag) => tag.toString())
          .toList(),
    );
  }
}

DateTime _readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
