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
      ),
    );

    try {

      final result = await task(
            (message) {
          final current = notifier.state;

          if (current == null) return;

          notifier.update(
            current.copyWith(
              message: message,
            ),
          );
        },
      );

      notifier.update(
        AppTask(
          id: id,
          type: type,
          status: AppTaskStatus.completed,
          title: title,
          payload: result,
        ),
      );

      return result;

    } catch (error) {

      notifier.update(
        AppTask(
          id: id,
          type: type,
          status: AppTaskStatus.failed,
          title: title,
          error: error,
        ),
      );

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

  void clear() {
    _ref.read(appTaskProvider.notifier).clear();
  }
}

final appTaskControllerProvider =
Provider<AppTaskController>(
      (ref) => AppTaskController(ref),
);