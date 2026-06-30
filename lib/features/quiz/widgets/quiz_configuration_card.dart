import 'package:flutter/material.dart';

import '../domain/question_type.dart';
import '../domain/quiz_difficulty.dart';

class QuizConfigurationCard extends StatelessWidget {
  const QuizConfigurationCard({
    super.key,
    required this.questionCount,
    required this.difficulty,
    required this.questionTypes,
    required this.extraInstructions,
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
}