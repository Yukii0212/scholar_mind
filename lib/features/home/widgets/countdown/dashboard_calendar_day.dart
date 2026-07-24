import 'package:flutter/material.dart';

import '../../../../core/theme/app_design.dart';

class DashboardCalendarDay extends StatelessWidget {
  const DashboardCalendarDay({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.eventCount,
    required this.onTap,
  });

  final DateTime? date;
  final bool isToday;
  final bool isSelected;
  final int eventCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (date == null) {
      return const SizedBox();
    }

    final palette = context.scholarPalette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? palette.brandStart.withValues(alpha: .18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isToday
                  ? palette.brandEnd
                  : palette.stroke,
            ),
          ),
          child: Column(
            children: [
              Text(
                '${date!.day}',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 12,
                child: _EventIndicator(
                  eventCount: eventCount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventIndicator extends StatelessWidget {
  const _EventIndicator({
    required this.eventCount,
  });

  final int eventCount;

  @override
  Widget build(BuildContext context) {
    if (eventCount <= 0) {
      return const SizedBox();
    }

    final color = Theme.of(context).colorScheme.primary;

    if (eventCount == 1) {
      return Center(
        child: _Dot(color: color),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Dot(color: color),
        const SizedBox(width: 4),
        _Dot(color: color),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}