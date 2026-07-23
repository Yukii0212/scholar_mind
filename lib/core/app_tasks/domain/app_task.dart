import 'app_task_status.dart';
import 'app_task_type.dart';

class AppTask {
  const AppTask({
    required this.id,
    required this.type,
    required this.status,
    this.title = '',
    this.message = '',
    this.payload,
    this.error,
  });

  final String id;
  final AppTaskType type;
  final AppTaskStatus status;

  final String title;
  final String message;

  final Object? payload;
  final Object? error;

  AppTask copyWith({
    AppTaskStatus? status,
    String? title,
    String? message,
    Object? payload,
    Object? error,
  }) {
    return AppTask(
      id: id,
      type: type,
      status: status ?? this.status,
      title: title ?? this.title,
      message: message ?? this.message,
      payload: payload ?? this.payload,
      error: error ?? this.error,
    );
  }
}