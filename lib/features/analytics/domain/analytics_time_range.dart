enum AnalyticsTimeRange {
  last7Days,
  last30Days,
  last3Months,
  allTime;

  String get label => switch (this) {
        AnalyticsTimeRange.last7Days => '7D',
        AnalyticsTimeRange.last30Days => '30D',
        AnalyticsTimeRange.last3Months => '3M',
        AnalyticsTimeRange.allTime => 'All',
      };

  /// Null for allTime -- callers should treat that as "no lower bound"
  /// rather than special-casing a sentinel date.
  DateTime? startDate(DateTime now) => switch (this) {
        AnalyticsTimeRange.last7Days =>
          now.subtract(const Duration(days: 7)),
        AnalyticsTimeRange.last30Days =>
          now.subtract(const Duration(days: 30)),
        AnalyticsTimeRange.last3Months =>
          DateTime(now.year, now.month - 3, now.day),
        AnalyticsTimeRange.allTime => null,
      };

  bool includes(DateTime date, {DateTime? now}) {
    final start = startDate(now ?? DateTime.now());
    return start == null || !date.isBefore(start);
  }
}
