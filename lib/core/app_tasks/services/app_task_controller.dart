import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_task.dart';
import '../domain/app_task_status.dart';
import '../domain/app_task_type.dart';
import '../providers/app_task_provider.dart';

class AppTaskController {
  AppTaskController(this._ref);

  final Ref _ref;

  Future<T> run<T>({
    required String id,
    required AppTaskType type,
    required String title,
    required Future<T> Function(
        void Function(String message) progress,
        ) task,
  }) async {
    final notifier =
    _ref.read(appTaskProvider.notifier);

    notifier.update(
      AppTask(
        id: id,
        type: type,
        status: AppTaskStatus.running,
        title: title,
        message: '',
        isCollapsed: false,
      ),
    );

    void progress(String message) {
      final current =
          notifier.currentTask;

      if (current == null ||
          current.id != id) {
        return;
      }

      notifier.update(
        current.copyWith(
          message: message,
        ),
      );
    }

    try {
      final result =
      await task(progress);

      final current =
          notifier.currentTask;

      if (current != null &&
          current.id == id) {
        notifier.update(
          current.copyWith(
            status: AppTaskStatus.completed,
            payload: result,
            completedAt: DateTime.now(),
            isCollapsed: false,
          ),
        );

        Timer(
          const Duration(minutes: 5),
          notifier.removeCompleted,
        );
      }

      return result;
    } catch (error) {
      final current =
          notifier.currentTask;

      if (current != null &&
          current.id == id) {
        notifier.update(
          current.copyWith(
            status: AppTaskStatus.failed,
            error: error,
            completedAt: DateTime.now(),
            isCollapsed: false,
          ),
        );

        Timer(
          const Duration(minutes: 5),
          notifier.removeCompleted,
        );
      }

      rethrow;
    }
  }

  void update({
    required String id,
    required AppTaskType type,
    required AppTaskStatus status,
    required String title,
    String message = '',
  }) {
    _ref.read(appTaskProvider.notifier).update(
      AppTask(
        id: id,
        type: type,
        status: status,
        title: title,
        message: message,
      ),
    );
  }

  void collapse(String id) {
    _ref
        .read(appTaskProvider.notifier)
        .collapse(id);
  }

  void expand(String id) {
    _ref
        .read(appTaskProvider.notifier)
        .expand(id);
  }

  void clear() {
    _ref.read(appTaskProvider.notifier).clear();
  }
}

final appTaskControllerProvider =
Provider<AppTaskController>(
      (ref) => AppTaskController(ref),
);