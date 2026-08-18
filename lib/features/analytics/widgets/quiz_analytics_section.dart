import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../../quiz/domain/question_type.dart';
import '../../quiz/domain/quiz_attempt.dart';
import '../../quiz/screens/quiz_result_screen.dart';
import '../../quiz/screens/quiz_viewer_screen.dart';
import '../domain/quiz_analytics.dart';
import '../providers/analytics_provider.dart';
import 'analytics_empty_state.dart';
import 'analytics_stat_tile.dart';

class QuizAnalyticsSection extends ConsumerWidget {
  const QuizAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(quizAnalyticsProvider);

    if (!summary.hasData) {
      return const AnalyticsEmptyState(
        icon: Icons.quiz_outlined,
        title: 'No quiz data yet',
        message: 'Take a quiz to start seeing your stats here.',
      );
    }

    final palette = context.scholarPalette;
    final recentAttempts = summary.recentAttempts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyticsStatGrid(
          tiles: [
            AnalyticsStatTile(
              icon: Icons.quiz_outlined,
              label: 'Quizzes completed',
              value: '${summary.completedAttempts}',
            ),
            AnalyticsStatTile(
              icon: Icons.percent_rounded,
              label: 'Average accuracy',
              value: summary.averageAccuracy == null
                  ? '—'
                  : '${summary.averageAccuracy!.round()}%',
              color: palette.success,
            ),
            AnalyticsStatTile(
              icon: Icons.checklist_rounded,
              label: 'Questions answered',
              value: '${summary.totalQuestionsAnswered}',
              color: palette.brandEnd,
            ),
            AnalyticsStatTile(
              icon: Icons.flag_outlined,
              label: 'Flagged questions',
              value: '${summary.flaggedCount}',
              color: palette.warning,
            ),
            if (summary.essayMax > 0)
              AnalyticsStatTile(
                icon: Icons.edit_note_rounded,
                label: 'Open-ended marks',
                value: '${summary.essayScore}/${summary.essayMax}',
                color: palette.brandStart,
              ),
          ],
        ),
        const Gap(20),
        if (summary.scoreTrend.length >= 2) ...[
          ScholarPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScholarSectionHeader(
                  title: 'Accuracy over time',
                  subtitle: 'Objective questions (multiple choice / true-false)',
                ),
                const Gap(16),
                SizedBox(
                  height: 200,
                  child: _AccuracyLineChart(trend: summary.scoreTrend),
                ),
              ],
            ),
          ),
          const Gap(20),
        ],
        if (summary.accuracyByType.isNotEmpty) ...[
          ScholarPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScholarSectionHeader(title: 'Accuracy by question type'),
                const Gap(16),
                SizedBox(
                  height: 200,
                  child: _QuestionTypeBarChart(
                    accuracyByType: summary.accuracyByType,
                  ),
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
              const ScholarSectionHeader(title: 'Recent attempts'),
              const Gap(14),
              for (final attempt in recentAttempts) ...[
                _RecentAttemptTile(attempt: attempt),
                if (attempt != recentAttempts.last) const Gap(8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AccuracyLineChart extends StatelessWidget {
  const _AccuracyLineChart({required this.trend});

  final List<QuizScorePoint> trend;

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
                '${point.name}\n${point.percentage.round()}%',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < trend.length; i++)
                FlSpot(i.toDouble(), trend[i].percentage),
            ],
            isCurved: true,
            color: palette.brandStart,
            barWidth: 3,
            dotData: FlDotData(show: trend.length <= 15),
            belowBarData: BarAreaData(
              show: true,
              color: palette.brandStart.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionTypeBarChart extends StatelessWidget {
  const _QuestionTypeBarChart({required this.accuracyByType});

  final List<QuestionTypeAccuracy> accuracyByType;

  static String _label(QuestionType type) => switch (type) {
        QuestionType.multipleChoice => 'MCQ',
        QuestionType.trueFalse => 'True/False',
        QuestionType.openEnded => 'Open-Ended',
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return BarChart(
      BarChartData(
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
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= accuracyByType.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _label(accuracyByType[index].type),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < accuracyByType.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: accuracyByType[i].percentage ?? 0,
                  color: palette.brandEnd,
                  width: 26,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RecentAttemptTile extends StatelessWidget {
  const _RecentAttemptTile({required this.attempt});

  final QuizAttempt attempt;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        attempt.status == QuizAttemptStatus.completed
            ? Icons.check_circle_outline
            : Icons.hourglass_top_outlined,
      ),
      title: Text(
        attempt.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        switch (attempt.status) {
          QuizAttemptStatus.inProgress => 'In Progress',
          QuizAttemptStatus.grading => 'Waiting for AI',
          QuizAttemptStatus.completed => 'Completed',
          QuizAttemptStatus.archived => 'Archived',
        },
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => attempt.status == QuizAttemptStatus.inProgress
                ? QuizViewerScreen(attempt: attempt)
                : QuizResultScreen(attempt: attempt),
          ),
        );
      },
    );
  }
}
