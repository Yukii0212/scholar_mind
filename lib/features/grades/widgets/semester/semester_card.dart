import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_design.dart';
import '../../data/models/semester_model.dart';

class SemesterCard extends StatelessWidget {
  const SemesterCard({
    super.key,
    required this.semester,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleHidden,
  });

  final SemesterModel semester;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onToggleHidden;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return ScholarPanel(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: const ScholarIconBadge(icon: Icons.school_rounded),
        title: Text(
          semester.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${DateFormat('MMM yyyy').format(semester.startDate)} - '
            '${DateFormat('MMM yyyy').format(semester.endDate)}',
            style: TextStyle(color: palette.textMuted),
          ),
        ),
        children: [
          _ActionTile(
            icon: Icons.open_in_new_rounded,
            title: 'Open',
            onTap: onOpen,
          ),
          _ActionTile(
            icon: Icons.edit_calendar_outlined,
            title: 'Edit Semester',
            onTap: onEdit,
          ),
          if (onToggleHidden != null)
            _ActionTile(
              icon: semester.isHidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              title: semester.isHidden ? 'Unhide' : 'Hide',
              onTap: onToggleHidden,
            ),
          _ActionTile(
            icon: Icons.delete_outline,
            title: 'Delete',
            color: Theme.of(context).colorScheme.error,
            onTap: onDelete,
          ),
        ],
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
