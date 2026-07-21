import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/study_streak_repository.dart';
import '../domain/study_streak_summary.dart';

final studyStreakRepositoryProvider = Provider<StudyStreakRepository>(
  (ref) => StudyStreakRepository(FirebaseFirestore.instance),
);

final studyStreakSummaryProvider = StreamProvider<StudyStreakSummary>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  return ref.watch(studyStreakRepositoryProvider).watchSummary(userId);
});

final studyStreakRecorderProvider = FutureProvider<void>((ref) async {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  await ref.watch(studyStreakRepositoryProvider).recordToday(userId);
});
