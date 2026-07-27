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

    final now = DateTime.now();
    final today = _dateId(now);
    final month = today.substring(0, 7);

    await _firestore.runTransaction((transaction) async {
      final reference = _summaryRef(userId);
      final snapshot = await transaction.get(reference);
      final current = StudyStreakSummary.fromFirestore(snapshot);

      final alreadyRecordedToday = current.lastStudyDate == today;

      final previousDate = current.lastStudyDate == null
          ? null
          : DateTime.tryParse(current.lastStudyDate!);
      final isConsecutive = previousDate != null &&
          _dateId(previousDate.add(const Duration(days: 1))) == today;
      final currentStreak = alreadyRecordedToday
          ? current.currentStreak
          : (isConsecutive ? current.currentStreak + 1 : 1);

      // dailyActivity only started being recorded once this feature shipped,
      // so an existing streak's earlier days are missing from the map even
      // though they genuinely happened. Since a streak is by definition
      // consecutive days ending on lastStudyDate, the whole range is safe to
      // (re)derive and backfill here every time, not just on new days.
      final dailyActivity = Map<String, bool>.of(current.dailyActivity);
      final todayDate = DateTime(now.year, now.month, now.day);
      for (var i = 0; i < currentStreak; i++) {
        dailyActivity[_dateId(todayDate.subtract(Duration(days: i)))] = true;
      }

      if (alreadyRecordedToday) {
        if (dailyActivity.length == current.dailyActivity.length) {
          return;
        }

        transaction.set(
          reference,
          {
            'dailyActivity': dailyActivity,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        return;
      }

      final longestStreak = currentStreak > current.longestStreak
          ? currentStreak
          : current.longestStreak;
      final monthlyActivity = Map<String, int>.of(current.monthlyActivity);
      monthlyActivity[month] = (monthlyActivity[month] ?? 0) + 1;
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
