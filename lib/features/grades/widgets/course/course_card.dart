import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_design.dart';
import '../../data/models/course_model.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.expanded,
    required this.onExpansionChanged,
  });

  final CourseModel course;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool expanded;
  final ValueChanged<bool> onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ScholarPanel(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          key: PageStorageKey(course.id),
          initiallyExpanded: expanded,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: const ScholarIconBadge(icon: Icons.menu_book_rounded),
          title: Text(
            course.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                _TargetChip(
                  label: course.targetScore == null
                      ? 'No target'
                      : 'Target ${course.targetScore!.toStringAsFixed(0)}%',
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    'Course tracker',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.textMuted),
                  ),
                ),
              ],
            ),
          ),
          children: [
            _ActionTile(
              icon: Icons.open_in_new_rounded,
              title: 'Open',
              onTap: onOpen,
            ),
            _ActionTile(
              icon: Icons.edit_outlined,
              title: 'Edit Course',
              onTap: onEdit,
            ),
            _ActionTile(
              icon: Icons.delete_outline,
              title: 'Delete',
              color: Theme.of(context).colorScheme.error,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.scholarPalette.brandStart.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.scholarPalette.brandEnd,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: onTap,
    );
  }
}
