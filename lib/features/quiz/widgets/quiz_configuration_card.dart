import 'package:flutter/material.dart';

import '../domain/assessment_mode.dart';
import '../domain/blooms_level.dart';
import '../domain/question_type.dart';
import '../domain/quiz_difficulty.dart';
import '../domain/question_type_weight.dart';

class QuizConfigurationCard extends StatelessWidget {
  const QuizConfigurationCard({
    super.key,
    required this.questionCount,
    required this.materialCharacterCount,
    required this.assessmentMode,
    required this.difficulty,
    required this.minimumBloomsLevel,
    required this.maximumBloomsLevel,
    required this.questionTypes,
    required this.extraInstructions,
    required this.questionTypeWeight,
    required this.onQuestionTypeWeightChanged,
    required this.onQuestionCountChanged,
    required this.onAssessmentModeChanged,
    required this.onDifficultyChanged,
    required this.onMinimumBloomsLevelChanged,
    required this.onMaximumBloomsLevelChanged,
    required this.onQuestionTypesChanged,
    required this.onExtraInstructionsChanged,
  });

  final int questionCount;

  /// Total character count across all selected, processed study
  /// materials. Used only to warn when it looks thin relative to
  /// [questionCount] -- generating that many genuinely distinct questions
  /// from very little source material tends to produce near-duplicates or
  /// reworded past-year questions instead.
  final int materialCharacterCount;

  final AssessmentMode assessmentMode;
  final QuizDifficulty difficulty;
  final BloomsLevel minimumBloomsLevel;
  final BloomsLevel maximumBloomsLevel;
  final List<QuestionType> questionTypes;
  final String extraInstructions;

  final ValueChanged<int> onQuestionCountChanged;

  final ValueChanged<AssessmentMode>
  onAssessmentModeChanged;

  final ValueChanged<QuizDifficulty>
  onDifficultyChanged;

  final ValueChanged<BloomsLevel>
  onMinimumBloomsLevelChanged;

  final ValueChanged<BloomsLevel>
  onMaximumBloomsLevelChanged;

  final ValueChanged<List<QuestionType>>
  onQuestionTypesChanged;

  final ValueChanged<String>
  onExtraInstructionsChanged;

  final QuestionTypeWeight
  questionTypeWeight;

  final ValueChanged<QuestionTypeWeight>
  onQuestionTypeWeightChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Configuration',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<int>(
              value: questionCount,
              decoration:
              const InputDecoration(
                labelText:
                'Question Count',
              ),
              items: const [
                5,
                10,
                15,
                20,
                25,
                30,
              ]
                  .map(
                    (count) =>
                    DropdownMenuItem(
                      value: count,
                      child: Text(
                        '$count Questions',
                      ),
                    ),
              )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onQuestionCountChanged(
                    value,
                  );
                }
              },
            ),

            const SizedBox(height: 6),

            Text(
              'This is a maximum -- fewer questions may be generated if '
              'that keeps quality higher than padding out to the full count.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),

            if (materialCharacterCount > 0 &&
                materialCharacterCount < questionCount * 400) ...[
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
                      'Your selected materials look thin for $questionCount '
                      'questions -- add more material or lower the count to '
                      'avoid repeated or reworded questions.',
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
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    size: 20,
                  ),
                  tooltip: 'Assessment Method',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) =>
                          AlertDialog(
                            title: const Text(
                              'Assessment Method',
                            ),
                            content: const SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisSize:
                                MainAxisSize.min,
                                children: [

                                  Text(
                                    'ScholarMind supports two methods for generating quizzes.',
                                  ),

                                  SizedBox(height: 20),

                                  Text(
                                    '📘 Informal Practice',
                                    style: TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  Text(
                                    'Recommended for everyday revision.\n\n'
                                        'ScholarMind estimates the overall difficulty of the quiz using Easy, Medium, Hard or Mixed.',
                                  ),

                                  SizedBox(height: 20),

                                  Text(
                                    '🎓 Formal Assessment',
                                    style: TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  Text(
                                    'Uses Bloom\'s Taxonomy, a framework commonly used by universities when designing assessments.\n\n'
                                        'Choose a minimum and maximum cognitive level and ScholarMind will generate questions only within that range.',
                                  ),

                                  SizedBox(height: 20),

                                  Text(
                                    'Bloom\'s Cognitive Levels',
                                    style: TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
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

                                  SizedBox(height: 20),

                                  Text(
                                    'Example',
                                    style: TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  Text(
                                    'Minimum: C2\n'
                                        'Maximum: C4\n\n'
                                        'Questions may assess Understanding, Application and Analysis only.',
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(
                                        dialogContext),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                    );
                  },
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
                onAssessmentModeChanged(
                  selection.first,
                );
              },
            ),

            const SizedBox(height: 20),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: assessmentMode ==
                  AssessmentMode.informal
                  ? DropdownButtonFormField<QuizDifficulty>(
                key: const ValueKey('informal'),
                value: difficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty',
                ),
                items: QuizDifficulty.values
                    .map(
                      (difficulty) =>
                      DropdownMenuItem(
                        value: difficulty,
                        child: Text(
                          difficulty.toString(),
                        ),
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
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  DropdownButtonFormField<
                      BloomsLevel>(
                    value: minimumBloomsLevel,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Minimum Cognitive Level',
                    ),
                    items: BloomsLevel.values
                        .map(
                          (level) =>
                          DropdownMenuItem(
                            value: level,
                            child: Text(
                              level.toString(),
                            ),
                          ),
                    )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onMinimumBloomsLevelChanged(
                          value,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<
                      BloomsLevel>(
                    value: maximumBloomsLevel,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Maximum Cognitive Level',
                    ),
                    items: BloomsLevel.values
                        .map(
                          (level) =>
                          DropdownMenuItem(
                            value: level,
                            child: Text(
                              level.toString(),
                            ),
                          ),
                    )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onMaximumBloomsLevelChanged(
                          value,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Question Types',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            CheckboxListTile(
              value: questionTypes.contains(
                QuestionType
                    .multipleChoice,
              ),
              title: const Text(
                'Multiple Choice',
              ),
              onChanged: (value) {
                final updated =
                List<QuestionType>.from(
                  questionTypes,
                );

                if (value == true) {
                  updated.add(
                    QuestionType.multipleChoice,
                  );
                } else {
                  if (updated.length == 1) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Select at least one question type.',
                        ),
                      ),
                    );
                    return;
                  }

                  updated.remove(
                    QuestionType.multipleChoice,
                  );
                }

                onQuestionTypesChanged(
                  updated.toSet().toList(),
                );
              },
            ),

            CheckboxListTile(
              value: questionTypes.contains(
                QuestionType.trueFalse,
              ),
              title: const Text(
                'True / False',
              ),
              onChanged: (value) {
                final updated =
                List<QuestionType>.from(
                  questionTypes,
                );

                if (value == true) {
                  updated.add(
                    QuestionType.trueFalse,
                  );
                } else {
                  if (updated.length == 1) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Select at least one question type.',
                        ),
                      ),
                    );
                    return;
                  }

                  updated.remove(
                    QuestionType.trueFalse,
                  );
                }

                onQuestionTypesChanged(
                  updated.toSet().toList(),
                );
              },
            ),

            CheckboxListTile(
              value: questionTypes.contains(
                QuestionType.openEnded,
              ),
              title: const Text(
                'Open Ended',
              ),
              onChanged: (value) {
                final updated =
                List<QuestionType>.from(
                  questionTypes,
                );

                if (value == true) {
                  updated.add(
                    QuestionType.openEnded,
                  );
                } else {
                  if (updated.length == 1) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Select at least one question type.',
                        ),
                      ),
                    );
                    return;
                  }

                  updated.remove(
                    QuestionType.openEnded,
                  );
                }

                onQuestionTypesChanged(
                  updated.toSet().toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Question Distribution',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    size: 20,
                  ),
                  tooltip: 'Question Distribution',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text(
                          'Question Distribution',
                        ),
                        content: const Text(
                          'By default, ScholarMind automatically balances the selected question types.\n\n'
                              'Customize this only if you want certain question types to appear more frequently than others.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            const SizedBox(height: 8),

            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Balanced'),
                  icon: Icon(Icons.check_circle_outline),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Custom'),
                  icon: Icon(Icons.tune),
                ),
              ],
              selected: {questionTypeWeight.isCustom},
              onSelectionChanged: (selection) async {
                final selectedCustom = selection.first;

                if (selectedCustom == questionTypeWeight.isCustom) {
                  return;
                }

                if (selectedCustom) {
                  onQuestionTypeWeightChanged(
                    _equalWeights(questionTypes),
                  );
                  return;
                }

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text(
                      'Switch to Balanced Distribution?',
                    ),
                    content: const Text(
                      'Your custom question distribution will be replaced with the recommended balanced distribution.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, true),
                        child: const Text('Switch'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  onQuestionTypeWeightChanged(
                    questionTypeWeight.copyWith(isCustom: false),
                  );
                }
              },
            ),

            const SizedBox(height: 8),

            AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 250,
              ),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder:
                  (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: !questionTypeWeight.isCustom
                  ? Text(
                      key: const ValueKey('balanced'),
                      'Balanced distribution is recommended for most quizzes.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    )
                  : Column(
                      key: const ValueKey('custom'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildQuestionTypeSliders(context),
                    ),
            ),

            TextFormField(
              initialValue:
              extraInstructions,
              decoration:
              const InputDecoration(
                labelText:
                'Extra Instructions',
                hintText:
                'Optional...',
              ),
              maxLines: 3,
              onChanged:
              onExtraInstructionsChanged,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildQuestionTypeSliders(
      BuildContext context,
      ) {
    final enabledTypes =
    questionTypes.toList();

    final weights = <QuestionType, int>{
      QuestionType.multipleChoice:
      questionTypeWeight.multipleChoice,
      QuestionType.trueFalse:
      questionTypeWeight.trueFalse,
      QuestionType.openEnded:
      questionTypeWeight.openEnded,
    };

    return [
      for (final type in enabledTypes)
        Padding(
          padding:
          const EdgeInsets.only(
            bottom: 12,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                '${_label(type)} (${weights[type]}%)',
              ),
              Slider(
                value:
                weights[type]!
                    .toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (value) {
                  final updated =
                  _redistribute(
                    type,
                    value.round(),
                    weights,
                    enabledTypes,
                  );

                  onQuestionTypeWeightChanged(
                    QuestionTypeWeight(
                      multipleChoice:
                      updated[
                      QuestionType.multipleChoice]!,
                      trueFalse:
                      updated[
                      QuestionType.trueFalse]!,
                      openEnded:
                      updated[
                      QuestionType.openEnded]!,
                      isCustom: true,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

      Padding(
        padding:
        const EdgeInsets.only(
          top: 8,
        ),
        child: Align(
          alignment:
          Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(
              Icons.refresh,
            ),
            label: const Text(
              'Reset to Equal',
            ),
            onPressed: () {
              onQuestionTypeWeightChanged(
                _equalWeights(
                  enabledTypes,
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  String _label(
      QuestionType type,
      ) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True / False';
      case QuestionType.openEnded:
        return 'Open Ended';
    }
  }

  QuestionTypeWeight _equalWeights(
      List<QuestionType> enabled,
      ) {
    final values = {
      QuestionType.multipleChoice: 0,
      QuestionType.trueFalse: 0,
      QuestionType.openEnded: 0,
    };

    final base =
        100 ~/ enabled.length;

    var remainder =
        100 % enabled.length;

    for (final type in enabled) {
      values[type] = base;

      if (remainder > 0) {
        values[type] =
            values[type]! + 1;
        remainder--;
      }
    }

    return QuestionTypeWeight(
      multipleChoice:
      values[
      QuestionType.multipleChoice]!,
      trueFalse:
      values[
      QuestionType.trueFalse]!,
      openEnded:
      values[
      QuestionType.openEnded]!,
      isCustom: true,
    );
  }

  Map<QuestionType, int>
  _redistribute(
      QuestionType changed,
      int newValue,
      Map<QuestionType, int> current,
      List<QuestionType> enabled,
      ) {
    final updated =
    Map<QuestionType, int>.from(
      current,
    );

    updated[changed] = newValue;

    final others =
    enabled.where(
          (e) => e != changed,
    );

    final remaining =
        100 - newValue;

    final totalOthers =
    others.fold(
      0,
          (sum, type) =>
      sum + updated[type]!,
    );

    if (totalOthers == 0) {
      final equal =
          remaining ~/
              others.length;

      for (final type in others) {
        updated[type] = equal;
      }

      return updated;
    }

    var allocated = 0;

    final otherList =
    others.toList();

    for (var i = 0;
    i < otherList.length;
    i++) {
      final type =
      otherList[i];

      if (i ==
          otherList.length -
              1) {
        updated[type] =
            remaining -
                allocated;
      } else {
        final value =
        ((updated[type]! /
            totalOthers) *
            remaining)
            .round();

        updated[type] =
            value;

        allocated += value;
      }
    }

    return updated;
  }
}