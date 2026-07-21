import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/countdown_repository.dart';
import '../domain/countdown_item.dart';

final countdownRepositoryProvider = Provider<CountdownRepository>(
  (ref) => CountdownRepository(FirebaseFirestore.instance),
);

final countdownsProvider = StreamProvider<List<CountdownItem>>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  return ref.watch(countdownRepositoryProvider).watchCountdowns(userId);
});

final upcomingCountdownsProvider = Provider<List<CountdownItem>>((ref) {
  final countdowns = ref.watch(countdownsProvider).valueOrNull ?? const [];
  return countdowns.where((item) => !item.isCompleted).toList();
});
