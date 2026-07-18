import 'package:cloud_firestore/cloud_firestore.dart';

class StudyStreakSummary {
  const StudyStreakSummary({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalStudyDays,
    required this.lastStudyDate,
    required this.monthlyActivity,
    required this.achievements,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalStudyDays;
  final String? lastStudyDate;
  final Map<String, int> monthlyActivity;
  final List<int> achievements;

  static const empty = StudyStreakSummary(
    currentStreak: 0,
    longestStreak: 0,
    totalStudyDays: 0,
    lastStudyDate: null,
    monthlyActivity: {},
    achievements: [],
  );

  factory StudyStreakSummary.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) return empty;

    return StudyStreakSummary(
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      totalStudyDays: data['totalStudyDays'] as int? ?? 0,
      lastStudyDate: data['lastStudyDate'] as String?,
      monthlyActivity: (data['monthlyActivity'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, (value as num).toInt())),
      achievements: (data['achievements'] as List<dynamic>? ?? [])
          .map((value) => (value as num).toInt())
          .toList(),
    );
  }
}
