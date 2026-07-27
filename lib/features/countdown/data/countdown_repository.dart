import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/countdown_item.dart';

class CountdownRepository {
  const CountdownRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('countdowns');
  }

  Stream<List<CountdownItem>> watchCountdowns(String? userId) {
    if (userId == null) return Stream.value(const []);

    return _collection(userId).snapshots().map((snapshot) {
      final items = snapshot.docs.map(CountdownItem.fromFirestore).toList();
      for (final item in items.where(_shouldAutoComplete)) {
        markCompleted(userId: userId, countdownId: item.id, completed: true);
      }

      return items
        ..sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }

          final priority = b.priority.compareTo(a.priority);
          if (priority != 0) return priority;
          return a.dueDate.compareTo(b.dueDate);
        });
    });
  }

  Future<CountdownItem?> getCountdown({
    required String userId,
    required String countdownId,
  }) async {
    final snapshot = await _collection(userId).doc(countdownId).get();

    if (!snapshot.exists) return null;

    return CountdownItem.fromFirestore(snapshot);
  }

  Future<String> importCountdown({
    required String userId,
    required String title,
    required CountdownType type,
    required int priority,
    required DateTime dueDate,
    required String? description,
    required bool deadlineExtendable,
  }) async {
    final now = DateTime.now();
    final reference = _collection(userId).doc();

    final item = CountdownItem(
      id: reference.id,
      title: title,
      type: type,
      priority: priority,
      dueDate: dueDate,
      description: description,
      deadlineExtendable: deadlineExtendable,
      isCompleted: false,
      isHidden: false,
      createdAt: now,
      updatedAt: now,
    );

    await reference.set(item.toFirestore());

    return reference.id;
  }

  Future<void> saveCountdown({
    required String userId,
    String? countdownId,
    required String title,
    required CountdownType type,
    required int priority,
    required DateTime dueDate,
    required String? description,
    required bool deadlineExtendable,
  }) async {
    final now = DateTime.now();
    final reference = countdownId == null
        ? _collection(userId).doc()
        : _collection(userId).doc(countdownId);

    final existing = countdownId == null ? null : await reference.get();
    final existingData = existing?.data();
    final createdAt = existingData?['createdAt'] as Timestamp?;
    final isCompleted = existingData?['isCompleted'] as bool? ?? false;
    final isHidden = existingData?['isHidden'] as bool? ?? false;

    final item = CountdownItem(
      id: reference.id,
      title: title,
      type: type,
      priority: priority,
      dueDate: dueDate,
      description: description,
      deadlineExtendable: deadlineExtendable,
      isCompleted: isCompleted,
      isHidden: isHidden,
      createdAt: createdAt?.toDate() ?? now,
      updatedAt: now,
    );

    await reference.set(item.toFirestore(), SetOptions(merge: true));
  }

  Future<void> markCompleted({
    required String userId,
    required String countdownId,
    required bool completed,
  }) {
    return _collection(userId).doc(countdownId).update({
      'isCompleted': completed,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteCountdown({
    required String userId,
    required String countdownId,
  }) {
    return _collection(userId).doc(countdownId).delete();
  }

  Future<void> setHidden({
    required String userId,
    required String countdownId,
    required bool hidden,
  }) {
    return _collection(userId).doc(countdownId).update({
      'isHidden': hidden,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  bool _shouldAutoComplete(CountdownItem item) {
    return !item.deadlineExtendable &&
        !item.isCompleted &&
        !item.isHidden &&
        item.daysRemaining < 0;
  }
}
