import 'package:flutter/material.dart';

import '../../quiz/domain/assessment_mode.dart';
import '../../quiz/domain/blooms_level.dart';
import '../../quiz/domain/quiz_difficulty.dart';

class FlashcardConfigurationCard extends StatelessWidget {
  const FlashcardConfigurationCard({
    super.key,
    required this.cardCount,
    required this.materialCharacterCount,
    required this.assessmentMode,
    required this.difficulty,
    required this.minimumBloomsLevel,
    required this.maximumBloomsLevel,
    required this.onCardCountChanged,
    required this.onAssessmentModeChanged,
    required this.onDifficultyChanged,
    required this.onMinimumBloomsLevelChanged,
    required this.onMaximumBloomsLevelChanged,
  });

  final int cardCount;

  /// Total character count across all selected, processed study
  /// materials -- used only to warn when it looks thin relative to
  /// [cardCount]. See QuizConfigurationCard's identical field for the
  /// same reasoning.
  final int materialCharacterCount;

  final AssessmentMode assessmentMode;
  final QuizDifficulty difficulty;
  final BloomsLevel minimumBloomsLevel;
  final BloomsLevel maximumBloomsLevel;

  final ValueChanged<int> onCardCountChanged;
  final ValueChanged<AssessmentMode> onAssessmentModeChanged;
  final ValueChanged<QuizDifficulty> onDifficultyChanged;
  final ValueChanged<BloomsLevel> onMinimumBloomsLevelChanged;
  final ValueChanged<BloomsLevel> onMaximumBloomsLevelChanged;

  static const _countOptions = [5, 10, 15, 20, 25, 30];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deck Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<int>(
              initialValue: cardCount,
              decoration: const InputDecoration(
                labelText: 'Card Count',
              ),
              items: [
                for (final count in _countOptions)
                  DropdownMenuItem(
                    value: count,
                    child: Text('$count Flashcards'),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onCardCountChanged(value);
                }
              },
            ),

            const SizedBox(height: 6),

            Text(
              'This is a maximum -- fewer cards may be generated if that '
              'keeps quality higher than padding out to the full count.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),

            if (materialCharacterCount > 0 &&
                materialCharacterCount < cardCount * 400) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Your selected materials look thin for $cardCount '
                      'flashcards -- add more material or lower the count '
                      'to avoid repeated or low-value cards.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Assessment Method',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 20),
                  tooltip: 'Assessment Method',
                  onPressed: () => _showAssessmentInfo(context),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SegmentedButton<AssessmentMode>(
              segments: const [
                ButtonSegment(
                  value: AssessmentMode.informal,
                  label: Text('Informal'),
                ),
                ButtonSegment(
                  value: AssessmentMode.formal,
                  label: Text('Formal'),
                ),
              ],
              selected: {assessmentMode},
              onSelectionChanged: (selection) {
                onAssessmentModeChanged(selection.first);
              },
            ),

            const SizedBox(height: 20),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: assessmentMode == AssessmentMode.informal
                  ? DropdownButtonFormField<QuizDifficulty>(
                      key: const ValueKey('informal'),
                      initialValue: difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                      ),
                      items: QuizDifficulty.values
                          .map(
                            (difficulty) => DropdownMenuItem(
                              value: difficulty,
                              child: Text(difficulty.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onDifficultyChanged(value);
                        }
                      },
                    )
                  : Column(
                      key: const ValueKey('formal'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<BloomsLevel>(
                          initialValue: minimumBloomsLevel,
                          decoration: const InputDecoration(
                            labelText: 'Minimum Cognitive Level',
                          ),
                          items: BloomsLevel.values
                              .map(
                                (level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(level.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              onMinimumBloomsLevelChanged(value);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<BloomsLevel>(
                          initialValue: maximumBloomsLevel,
                          decoration: const InputDecoration(
                            labelText: 'Maximum Cognitive Level',
                          ),
                          items: BloomsLevel.values
                              .map(
                                (level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(level.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              onMaximumBloomsLevelChanged(value);
                            }
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssessmentInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Assessment Method'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ScholarMind supports two methods for generating flashcards.',
              ),
              SizedBox(height: 20),
              Text(
                '📘 Informal Practice',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Recommended for everyday revision.\n\n'
                'ScholarMind estimates the overall difficulty of the deck '
                'using Easy, Medium, Hard or Mixed.',
              ),
              SizedBox(height: 20),
              Text(
                '🎓 Formal Assessment',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Uses Bloom\'s Taxonomy, a framework commonly used by '
                'universities when designing assessments.\n\n'
                'Choose a minimum and maximum cognitive level and '
                'ScholarMind will generate flashcards only within that '
                'range.',
              ),
              SizedBox(height: 20),
              Text(
                'Bloom\'s Cognitive Levels',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('C1 • Remember'),
              Text('Recall facts and definitions.'),
              SizedBox(height: 12),
              Text('C2 • Understand'),
              Text('Explain concepts and ideas.'),
              SizedBox(height: 12),
              Text('C3 • Apply'),
              Text('Use knowledge to solve problems.'),
              SizedBox(height: 12),
              Text('C4 • Analyze'),
              Text('Compare, examine and investigate.'),
              SizedBox(height: 12),
              Text('C5 • Evaluate'),
              Text('Justify decisions and make judgments.'),
              SizedBox(height: 12),
              Text('C6 • Create'),
              Text('Design or produce original solutions.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
