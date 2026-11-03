import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/study_streak_repository.dart';
import '../domain/study_streak_summary.dart';

final studyStreakRepositoryProvider = Provider<StudyStreakRepository>(
  (ref) => StudyStreakRepository(FirebaseFirestore.instance),
);

final studyStreakSummaryProvider = StreamProvider<StudyStreakSummary>((ref) {
  final userId = ref.watch(activeUserProvider)?.uid;
  return ref.watch(studyStreakRepositoryProvider).watchSummary(userId);
});

final studyStreakRecorderProvider = FutureProvider<void>((ref) async {
  final userId = ref.watch(activeUserProvider)?.uid;

  final now = DateTime.now();
  final nextDay = DateTime(now.year, now.month, now.day + 1);
  final refreshTimer = Timer(
    nextDay.difference(now) + const Duration(seconds: 1),
    ref.invalidateSelf,
  );
  ref.onDispose(refreshTimer.cancel);

  await ref.watch(studyStreakRepositoryProvider).recordToday(userId);
});
