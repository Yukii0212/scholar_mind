import 'package:flutter/material.dart';
import 'empty_state.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
  });
  final String message;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Could not load notes',
      message: message,
    );
  }
}
