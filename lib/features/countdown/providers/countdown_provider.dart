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

  final upcoming = countdowns
      .where((item) => !item.isEffectivelyCompleted)
      .toList();

  upcoming.sort((a, b) {
    final bucketCompare =
    _bucketFor(a.daysRemaining).compareTo(_bucketFor(b.daysRemaining));

    if (bucketCompare != 0) {
      return bucketCompare;
    }

    final priorityCompare = b.priority.compareTo(a.priority);
    if (priorityCompare != 0) {
      return priorityCompare;
    }

    return a.dueDate.compareTo(b.dueDate);
  });

  return upcoming;
});

int _bucketFor(int daysRemaining) {
  if (daysRemaining < 3) {
    return 0;
  }

  if (daysRemaining < 7) {
    return 1;
  }

  if (daysRemaining < 30) {
    return 2;
  }

  return 3;
}
