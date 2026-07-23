import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_task.dart';

final appTaskProvider =
StateNotifierProvider<AppTaskController, AppTask?>(
      (_) => AppTaskController(),
);

class AppTaskController extends StateNotifier<AppTask?> {
  AppTaskController() : super(null);

  bool get isRunning =>
      state != null &&
          state!.status.index < 4;

  void update(AppTask task) {
    state = task;
  }

  void clear() {
    state = null;
  }
}