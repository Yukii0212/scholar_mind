import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/providers/auth_provider.dart';
import '../domain/app_task.dart';
import '../domain/app_task_status.dart';
import '../domain/app_task_type.dart';
import '../providers/app_task_provider.dart';

class AppTaskSessionChangedException implements Exception {
  const AppTaskSessionChangedException();

  @override
  String toString() {
    return 'The signed-in account changed while the task was running.';
  }
}

class AppTaskSession {
  const AppTaskSession._({
    required this.userId,
    required bool Function() isCurrent,
  }) : _isCurrent = isCurrent;

  final String? userId;
  final bool Function() _isCurrent;

  bool get isCurrent => _isCurrent();

  void throwIfChanged() {
    if (!isCurrent) {
      throw const AppTaskSessionChangedException();
    }
  }
}

class AppTaskController {
  AppTaskController(this._ref) {
    _ref.listen(activeUserProvider, (previous, next) {
      if (previous?.uid != next?.uid) {
        _sessionRevision++;
      }
    });
  }

  final Ref _ref;
  int _sessionRevision = 0;

  Future<T> run<T>({
    required String id,
    required AppTaskType type,
    required String title,
    required Future<T> Function(
      void Function(String message) progress,
    ) task,
    void Function(BuildContext context, AppTask task)? onOpen,
  }) {
    return _run(
      id: id,
      type: type,
      title: title,
      task: (_, progress) => task(progress),
      onOpen: onOpen,
    );
  }

  Future<T> runSession<T>({
    required String id,
    required AppTaskType type,
    required String title,
    required Future<T> Function(
      AppTaskSession session,
      void Function(String message) progress,
    ) task,
    void Function(BuildContext context, AppTask task)? onOpen,
  }) {
    return _run(
      id: id,
      type: type,
      title: title,
      task: task,
      onOpen: onOpen,
    );
  }

  Future<T> _run<T>({
    required String id,
    required AppTaskType type,
    required String title,
    required Future<T> Function(
      AppTaskSession session,
      void Function(String message) progress,
    ) task,
    void Function(BuildContext context, AppTask task)? onOpen,
  }) async {
    final notifier = _ref.read(appTaskProvider.notifier);
    final sessionUserId = _ref.read(activeUserProvider)?.uid;
    final sessionRevision = _sessionRevision;

    final session = AppTaskSession._(
      userId: sessionUserId,
      isCurrent: () {
        return _sessionRevision == sessionRevision &&
            _ref.read(activeUserProvider)?.uid == sessionUserId;
      },
    );

    void ensureSameSession() {
      session.throwIfChanged();
    }

    notifier.update(
      AppTask(
        id: id,
        type: type,
        status: AppTaskStatus.running,
        title: title,
        message: '',
        isCollapsed: false,
        onOpen: onOpen,
      ),
    );

    void progress(String message) {
      ensureSameSession();

      // Looked up by this task's own id, not notifier.currentTask (the
      // most-recently-touched task across the WHOLE app) -- with two
      // background tasks running concurrently (e.g. flashcard + quiz
      // generation together), currentTask would resolve to whichever one
      // was touched more recently, silently dropping progress/completion
      // updates for the other one, which would then be stuck showing as
      // "running" forever even after its own work actually finished.
      final current = notifier.taskById(id);

      if (current == null) {
        return;
      }

      notifier.update(
        current.copyWith(
          message: message,
        ),
      );
    }

    try {
      ensureSameSession();

      final result = await task(session, progress);

      ensureSameSession();

      final current = notifier.taskById(id);

      if (current != null) {
        notifier.update(
          current.copyWith(
            status: AppTaskStatus.completed,
            payload: result,
            completedAt: DateTime.now(),
            isCollapsed: false,
          ),
        );

        Timer(
          const Duration(seconds: 5),
          notifier.removeCompleted,
        );
      }

      return result;
    } catch (error, stackTrace) {
      if (error is AppTaskSessionChangedException || !session.isCurrent) {
        notifier.remove(id);

        if (error is AppTaskSessionChangedException) {
          rethrow;
        }

        Error.throwWithStackTrace(
          const AppTaskSessionChangedException(),
          stackTrace,
        );
      }

      final current = notifier.taskById(id);

      if (current != null) {
        notifier.update(
          current.copyWith(
            status: AppTaskStatus.failed,
            error: error,
            completedAt: DateTime.now(),
            isCollapsed: false,
          ),
        );

        Timer(
          const Duration(seconds: 5),
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
    _ref.read(appTaskProvider.notifier).collapse(id);
  }

  void expand(String id) {
    _ref.read(appTaskProvider.notifier).expand(id);
  }

  void clear() {
    _ref.read(appTaskProvider.notifier).clear();
  }
}

final appTaskControllerProvider = Provider<AppTaskController>(
  (ref) => AppTaskController(ref),
);
