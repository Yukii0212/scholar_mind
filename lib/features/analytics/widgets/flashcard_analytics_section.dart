import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../../flashcards/providers/flashcard_provider.dart';
import '../../flashcards/screens/flashcard_set_detail_screen.dart';
import '../domain/flashcard_analytics.dart';
import '../providers/analytics_provider.dart';
import 'analytics_empty_state.dart';
import 'analytics_stat_tile.dart';

class FlashcardAnalyticsSection extends ConsumerWidget {
  const FlashcardAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(flashcardAnalyticsProvider);

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Unable to load flashcard analytics: $error'),
      ),
      data: (summary) {
        if (!summary.hasData) {
          return const AnalyticsEmptyState(
            icon: Icons.style_outlined,
            title: 'No flashcard data yet',
            message: 'Create a set and study it to start seeing your stats here.',
          );
        }

        final palette = context.scholarPalette;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnalyticsStatGrid(
              tiles: [
                AnalyticsStatTile(
                  icon: Icons.style_outlined,
                  label: 'Sets studied',
                  value: '${summary.perSetBreakdown.length}',
                ),
                AnalyticsStatTile(
                  icon: Icons.percent_rounded,
                  label: 'Known rate',
                  value: summary.overallKnownRate == null
                      ? '—'
                      : '${summary.overallKnownRate!.round()}%',
                  color: palette.success,
                ),
                AnalyticsStatTile(
                  icon: Icons.play_circle_outline,
                  label: 'Sessions completed',
                  value: '${summary.totalSessions}',
                  color: palette.brandEnd,
                ),
                AnalyticsStatTile(
                  icon: Icons.style_outlined,
                  label: 'Flashcards reviewed',
                  value: '${summary.totalCardsReviewed}',
                  color: palette.warning,
                ),
              ],
            ),
            const Gap(20),
            if (summary.sessionTrend.length >= 2) ...[
              ScholarPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScholarSectionHeader(
                      title: 'Known rate over time',
                      subtitle: 'One point per completed study session',
                    ),
                    const Gap(16),
                    SizedBox(
                      height: 200,
                      child: _KnownRateLineChart(trend: summary.sessionTrend),
                    ),
                  ],
                ),
              ),
              const Gap(20),
            ],
            ScholarPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScholarSectionHeader(title: 'By set'),
                  const Gap(14),
                  for (final set in summary.perSetBreakdown) ...[
                    _SetBreakdownTile(breakdown: set),
                    if (set != summary.perSetBreakdown.last) const Gap(8),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KnownRateLineChart extends StatelessWidget {
  const _KnownRateLineChart({required this.trend});

  final List<FlashcardSessionRecord> trend;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) => FlLine(
            color: palette.stroke.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 25,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) {
              final point = trend[spot.x.toInt()];
              return LineTooltipItem(
                '${point.setName}\n${point.knownRate?.round() ?? 0}%',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < trend.length; i++)
                FlSpot(i.toDouble(), trend[i].knownRate ?? 0),
            ],
            isCurved: true,
            color: palette.brandEnd,
            barWidth: 3,
            dotData: FlDotData(show: trend.length <= 15),
            belowBarData: BarAreaData(
              show: true,
              color: palette.brandEnd.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetBreakdownTile extends StatelessWidget {
  const _SetBreakdownTile({required this.breakdown});

  final FlashcardSetBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final sets = ref.watch(flashcardSetsProvider).valueOrNull ?? const [];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.style_outlined),
          title: Text(
            breakdown.setName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${breakdown.sessionsCompleted} session'
            '${breakdown.sessionsCompleted == 1 ? '' : 's'}'
            '${breakdown.knownRate == null ? '' : ' • ${breakdown.knownRate!.round()}% known'}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            final set = sets
                .where((candidate) => candidate.id == breakdown.setId)
                .firstOrNull;

            if (set == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This set is no longer available.'),
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FlashcardSetDetailScreen(flashcardSet: set),
              ),
            );
          },
        );
      },
    );
  }
}
