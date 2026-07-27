import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/study_streak_summary.dart';

class StudyStreakRepository {
  const StudyStreakRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _summaryRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('study_streak')
        .doc('summary');
  }

  Stream<StudyStreakSummary> watchSummary(String? userId) {
    if (userId == null) {
      return Stream.value(StudyStreakSummary.empty);
    }

    return _summaryRef(userId).snapshots().map(
          StudyStreakSummary.fromFirestore,
        );
  }

  Future<void> recordToday(String? userId) async {
    if (userId == null) return;

    final today = _dateId(DateTime.now());
    final month = today.substring(0, 7);

    await _firestore.runTransaction((transaction) async {
      final reference = _summaryRef(userId);
      final snapshot = await transaction.get(reference);
      final current = StudyStreakSummary.fromFirestore(snapshot);

      if (current.lastStudyDate == today) {
        return;
      }

      final previousDate = current.lastStudyDate == null
          ? null
          : DateTime.tryParse(current.lastStudyDate!);
      final isConsecutive = previousDate != null &&
          _dateId(previousDate.add(const Duration(days: 1))) == today;
      final currentStreak = isConsecutive ? current.currentStreak + 1 : 1;
      final longestStreak = currentStreak > current.longestStreak
          ? currentStreak
          : current.longestStreak;
      final monthlyActivity = Map<String, int>.of(current.monthlyActivity);
      monthlyActivity[month] = (monthlyActivity[month] ?? 0) + 1;
      final dailyActivity = Map<String, bool>.of(current.dailyActivity);
      dailyActivity[today] = true;
      final achievements = {
        ...current.achievements,
        for (final threshold in _achievementThresholds)
          if (currentStreak >= threshold) threshold,
      }.toList()
        ..sort();

      transaction.set(
        reference,
        {
          'currentStreak': currentStreak,
          'longestStreak': longestStreak,
          'totalStudyDays': current.totalStudyDays + 1,
          'lastStudyDate': today,
          'monthlyActivity': monthlyActivity,
          'dailyActivity': dailyActivity,
          'achievements': achievements,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  static String _dateId(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}

const _achievementThresholds = [3, 7, 14, 30, 100];
