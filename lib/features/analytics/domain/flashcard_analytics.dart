/// One completed study session, denormalized with the set's name so the
/// trend chart/list doesn't need a second lookup per point.
class FlashcardSessionRecord {
  const FlashcardSessionRecord({
    required this.setId,
    required this.setName,
    required this.reviewed,
    required this.known,
    required this.needsReview,
    required this.completedAt,
  });

  final String setId;
  final String setName;
  final int reviewed;
  final int known;
  final int needsReview;
  final DateTime completedAt;

  double? get knownRate => reviewed == 0 ? null : (known / reviewed) * 100;
}

class FlashcardSetBreakdown {
  const FlashcardSetBreakdown({
    required this.setId,
    required this.setName,
    required this.cardCount,
    required this.sessionsCompleted,
    required this.knownCards,
    required this.needsReviewCards,
  });

  final String setId;
  final String setName;
  final int cardCount;
  final int sessionsCompleted;

  // Cumulative across every session ever recorded for this set (not a
  // per-card current-mastery count) -- see FlashcardSet.knownCards.
  final int knownCards;
  final int needsReviewCards;

  double? get knownRate {
    final total = knownCards + needsReviewCards;
    return total == 0 ? null : (knownCards / total) * 100;
  }
}

class FlashcardAnalyticsSummary {
  const FlashcardAnalyticsSummary({
    required this.totalSets,
    required this.totalSessions,
    required this.totalCardsReviewed,
    required this.overallKnownRate,
    required this.sessionTrend,
    required this.perSetBreakdown,
  });

  static const empty = FlashcardAnalyticsSummary(
    totalSets: 0,
    totalSessions: 0,
    totalCardsReviewed: 0,
    overallKnownRate: null,
    sessionTrend: [],
    perSetBreakdown: [],
  );

  final int totalSets;
  final int totalSessions;
  final int totalCardsReviewed;
  final double? overallKnownRate;

  /// Chronological (oldest first), so charts read left-to-right.
  final List<FlashcardSessionRecord> sessionTrend;

  final List<FlashcardSetBreakdown> perSetBreakdown;

  bool get hasData => totalSets > 0;
}
