import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_design.dart';

class SemesterPanel extends StatelessWidget {
  const SemesterPanel({
    required this.semesterName,
    required this.courseCount,
    required this.averageScore,
  });

  final String? semesterName;
  final int courseCount;
  final double? averageScore;

  @override
  Widget build(BuildContext context) {
    final value = averageScore == null ? 0.0 : averageScore! / 100;

    return ScholarPanel(
      onTap: () => context.go('/grades'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScholarSectionHeader(
            title: 'This Semester',
          ),
          const Gap(16),
          Center(
            child: SizedBox(
              width: 142,
              height: 142,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: value.clamp(0, 1),
                      strokeWidth: 9,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        averageScore == null
                            ? '--'
                            : averageScore!.toStringAsFixed(1),
                        style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        semesterName ?? 'No semester',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.scholarPalette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(label: 'Courses', value: '$courseCount'),
              ),
              const Gap(8),
              Expanded(
                child: _MiniStat(
                  label: 'Avg Score',
                  value: averageScore == null
                      ? '--'
                      : '${averageScore!.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.scholarPalette.panelStrong.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.scholarPalette.stroke),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.scholarPalette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}