import 'package:cloud_firestore/cloud_firestore.dart';

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

class FlashcardDeck {
  const FlashcardDeck({
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
  final DateTime createdAt;
  final DateTime updatedAt;

  factory FlashcardDeck.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    return FlashcardDeck(
      id: doc.id,
      name: data['name'] as String? ?? 'Untitled Deck',
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

class GeneratedFlashcardDeck {
  const GeneratedFlashcardDeck({
    required this.title,
    required this.cards,
  });

  final String title;
  final List<GeneratedFlashcard> cards;

  factory GeneratedFlashcardDeck.fromJson(Map<String, dynamic> json) {
    return GeneratedFlashcardDeck(
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
