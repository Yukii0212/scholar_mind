import 'app_task_status.dart';
import 'app_task_type.dart';

const _unset = Object();

class AppTask {
  const AppTask({
    required this.id,
    required this.type,
    required this.status,
    this.title = '',
    this.message = '',
    this.payload,
    this.error,
    this.completedAt,
  });

  final String id;
  final AppTaskType type;
  final AppTaskStatus status;

  final String title;
  final String message;

  final Object? payload;
  final Object? error;

  final DateTime? completedAt;

  AppTask copyWith({
    AppTaskStatus? status,
    String? title,
    String? message,
    Object? payload = _unset,
    Object? error = _unset,
    Object? completedAt = _unset,
  }) {
    return AppTask(
      id: id,
      type: type,
      status: status ?? this.status,
      title: title ?? this.title,
      message: message ?? this.message,
      payload: identical(payload, _unset)
          ? this.payload
          : payload,
      error: identical(error, _unset)
          ? this.error
          : error,
      completedAt: identical(completedAt, _unset)
          ? this.completedAt
          : completedAt as DateTime?,
    );
  }
}