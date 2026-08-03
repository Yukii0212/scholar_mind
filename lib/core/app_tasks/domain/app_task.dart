import 'package:flutter/widgets.dart';

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
    this.isCollapsed = false,
    this.onOpen,
  });

  final String id;
  final AppTaskType type;
  final AppTaskStatus status;

  final String title;
  final String message;

  final Object? payload;
  final Object? error;

  final DateTime? completedAt;

  final bool isCollapsed;

  // Lets a task point at where its result actually lives — a single
  // AppTaskType (e.g. flashcardGeneration) can originate from many
  // different screens, so this is captured per task instance rather than
  // mapped statically per type. Tasks that don't set it fall back to the
  // generic AppTaskDetailsScreen (see AppTaskBanner's tap handler).
  final void Function(BuildContext context, AppTask task)? onOpen;

  AppTask copyWith({
    AppTaskStatus? status,
    String? title,
    String? message,
    Object? payload = _unset,
    Object? error = _unset,
    Object? completedAt = _unset,
    bool? isCollapsed,
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
      isCollapsed:
      isCollapsed ?? this.isCollapsed,
      onOpen: onOpen,
    );
  }
}