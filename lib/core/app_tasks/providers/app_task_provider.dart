import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_task.dart';
import '../domain/app_task_status.dart';

final appTaskProvider =
StateNotifierProvider<AppTaskController, List<AppTask>>(
      (_) => AppTaskController(),
);

class AppTaskController extends StateNotifier<List<AppTask>> {
  AppTaskController() : super(const []);

  bool get isRunning =>
      state.any((task) => task.status.index < AppTaskStatus.completed.index);

  AppTask? get currentTask {
    for (final task in state.reversed) {
      if (task.status != AppTaskStatus.completed &&
          task.status != AppTaskStatus.failed) {
        return task;
      }
    }

    if (state.isEmpty) {
      return null;
    }

    return state.last;
  }

  AppTask? taskById(String id) {
    for (final task in state) {
      if (task.id == id) {
        return task;
      }
    }

    return null;
  }

  void update(AppTask task) {
    final index = state.indexWhere((t) => t.id == task.id);

    if (index == -1) {
      state = [...state, task];
      return;
    }

    final updated = [...state];
    updated[index] = task;
    state = updated;
  }

  void remove(String id) {
    state = state.where((task) => task.id != id).toList();
  }

  void clear() {
    state = const [];
  }
}