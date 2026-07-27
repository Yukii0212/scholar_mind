import 'package:flutter/material.dart';

class ExportCartModuleHeader extends StatelessWidget {
  const ExportCartModuleHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(16),
                color: theme.colorScheme.primary
                    .withValues(alpha: .12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:
                    theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: expanded ? .5 : 0,
              duration: const Duration(
                milliseconds: 200,
              ),
              child: const Icon(
                Icons.keyboard_arrow_down,
              ),
            ),
          ],
        ),
      ),
    );
  }
}