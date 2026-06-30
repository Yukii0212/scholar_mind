import 'package:flutter/material.dart';

import '../domain/question_type.dart';
import '../domain/quiz_difficulty.dart';
import '../domain/question_type_weight.dart';

class QuizConfigurationCard extends StatelessWidget {
  const QuizConfigurationCard({
    super.key,
    required this.questionCount,
    required this.difficulty,
    required this.questionTypes,
    required this.extraInstructions,
    required this.questionTypeWeight,
    required this.onQuestionTypeWeightChanged,
    required this.onQuestionCountChanged,
    required this.onDifficultyChanged,
    required this.onQuestionTypesChanged,
    required this.onExtraInstructionsChanged,
  });

  final int questionCount;
  final QuizDifficulty difficulty;
  final List<QuestionType> questionTypes;
  final String extraInstructions;

  final ValueChanged<int> onQuestionCountChanged;
  final ValueChanged<QuizDifficulty>
  onDifficultyChanged;
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

            const SizedBox(height: 20),

            DropdownButtonFormField<
                QuizDifficulty>(
              value: difficulty,
              decoration:
              const InputDecoration(
                labelText: 'Difficulty',
              ),
              items:
              QuizDifficulty.values
                  .map(
                    (difficulty) =>
                    DropdownMenuItem(
                      value:
                      difficulty,
                      child: Text(
                        difficulty
                            .toString(),
                      ),
                    ),
              )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onDifficultyChanged(
                    value,
                  );
                }
              },
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

            if (!questionTypeWeight.isCustom) ...[
              Chip(
                backgroundColor:
                Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                avatar: const Icon(
                  Icons.check_circle_outline,
                  size: 18,
                ),
                label: const Text(
                  'Balanced (Recommended)',
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    onQuestionTypeWeightChanged(
                      _equalWeights(
                        questionTypes,
                      ),
                    );
                  },
                  child: const Text(
                    'Customize',
                  ),
                ),
              ),
            ] else ...[
              Chip(
                backgroundColor:
                Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                avatar: const Icon(
                  Icons.tune,
                  size: 18,
                ),
                label: const Text(
                  'Custom',
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    final discard =
                    await showDialog<bool>(
                      context: context,
                      builder:
                          (dialogContext) =>
                          AlertDialog(
                            title: const Text(
                              'Discard Custom Distribution?',
                            ),
                            content: const Text(
                              'Your custom question distribution will be discarded and ScholarMind will use the recommended balanced distribution instead.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    dialogContext,
                                    false,
                                  );
                                },
                                child: const Text(
                                  'Cancel',
                                ),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(
                                    dialogContext,
                                    true,
                                  );
                                },
                                child: const Text(
                                  'Discard',
                                ),
                              ),
                            ],
                          ),
                    );

                    if (discard == true) {
                      onQuestionTypeWeightChanged(
                        questionTypeWeight.copyWith(
                          isCustom: false,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Discard',
                  ),
                ),
              ),

              const SizedBox(height: 8),

              ..._buildQuestionTypeSliders(
                context,
              ),
            ],

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