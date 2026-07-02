import 'package:flutter/material.dart';

class StudyMaterialFolderCard extends StatelessWidget {
  const StudyMaterialFolderCard({
    super.key,
    required this.name,
    required this.isFavorite,
    required this.onTap,
  });

  final String name;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              Icon(
                Icons.folder,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (isFavorite)
                Icon(
                  Icons.star,
                  size: 18,
                  color: Theme.of(context).colorScheme.tertiary,
                ),

              const SizedBox(width: 8),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}