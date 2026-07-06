import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GradeEmptyState extends StatelessWidget {
  const GradeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'No semester found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Create your first semester from the + menu to start tracking your grades.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}