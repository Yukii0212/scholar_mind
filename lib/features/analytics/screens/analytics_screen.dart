import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_design.dart';
import '../domain/analytics_time_range.dart';
import '../providers/analytics_provider.dart';
import '../widgets/flashcard_analytics_section.dart';
import '../widgets/quiz_analytics_section.dart';

enum _AnalyticsTab { quiz, flashcards }

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  var _tab = _AnalyticsTab.quiz;

  @override
  Widget build(BuildContext context) {
    final timeRange = ref.watch(analyticsTimeRangeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScholarSectionHeader(
                      title: 'Analytics',
                      subtitle:
                          'How you\'re doing across quizzes and flashcards',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          'Showing',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SegmentedButton<AnalyticsTimeRange>(
                            showSelectedIcon: false,
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                            segments: [
                              for (final range in AnalyticsTimeRange.values)
                                ButtonSegment(
                                  value: range,
                                  label: Text(range.label),
                                ),
                            ],
                            selected: {timeRange},
                            onSelectionChanged: (selection) {
                              ref
                                  .read(analyticsTimeRangeProvider.notifier)
                                  .state = selection.first;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<_AnalyticsTab>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: _AnalyticsTab.quiz,
                            icon: Icon(Icons.quiz_outlined),
                            label: Text('Quiz'),
                          ),
                          ButtonSegment(
                            value: _AnalyticsTab.flashcards,
                            icon: Icon(Icons.style_outlined),
                            label: Text('Flashcards'),
                          ),
                        ],
                        selected: {_tab},
                        onSelectionChanged: (selection) {
                          setState(() => _tab = selection.first);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    switch (_tab) {
                      _AnalyticsTab.quiz => const QuizAnalyticsSection(),
                      _AnalyticsTab.flashcards =>
                        const FlashcardAnalyticsSection(),
                    },
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
