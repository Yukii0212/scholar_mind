import 'package:flutter/material.dart';

import '../../../domain/assessment/score_interpretation.dart';
import '../../../domain/assessment/score_interpreter.dart';

class AssessmentEntryDialog
    extends StatefulWidget {
  const AssessmentEntryDialog({
    super.key,
    required this.title,
    required this.componentWeight,
    required this.overallWeight,
    required this.isPrediction,
  });

  final String title;

  final double componentWeight;

  final double overallWeight;

  final bool isPrediction;

  @override
  State<AssessmentEntryDialog> createState() =>
      _AssessmentEntryDialogState();
}

class _AssessmentEntryDialogState
    extends State<AssessmentEntryDialog> {

  final _scoreController =
  TextEditingController();

  final _denominatorController =
  TextEditingController(
    text: '100',
  );

  ScoreInterpretationResult?
  _interpretation;

  @override
  void dispose() {
    _scoreController.dispose();
    _denominatorController.dispose();
    super.dispose();
  }

  void _updateInterpretation() {
    final score = double.tryParse(
      _scoreController.text,
    );

    final denominator =
    double.tryParse(
      _denominatorController.text,
    );

    if (score == null ||
        denominator == null ||
        denominator <= 0) {
      setState(() {
        _interpretation = null;
      });
      return;
    }

    setState(() {
      _interpretation =
          ScoreInterpreter.interpret(
            score: score,
            denominator: denominator,
            componentWeight:
            widget.componentWeight,
            overallWeight:
            widget.overallWeight,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isPrediction
            ? 'Expected Score'
            : 'Actual Score',
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Text(
              widget.isPrediction
                  ? 'How much do you expect to score?'
                  : 'How much did you score?',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller:
                    _scoreController,
                    onChanged: (_) =>
                        _updateInterpretation(),
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                    const InputDecoration(
                      labelText: 'Score',
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: TextField(
                    controller:
                    _denominatorController,
                    onChanged: (_) =>
                        _updateInterpretation(),
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                    const InputDecoration(
                      labelText: 'Out of',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (_interpretation != null)
              Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                child: Padding(
                  padding:
                  const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        'ScholarMind recognised this as',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge,
                      ),

                      const SizedBox(height: 8),

                      Builder(
                        builder: (_) {
                          switch (_interpretation!
                              .interpretation) {

                            case ScoreInterpretation
                                .percentage:
                              return const Text(
                                'Percentage (x / 100)',
                              );

                            case ScoreInterpretation
                                .componentWeight:
                              return Text(
                                'Component weighting (x / ${widget.componentWeight.toStringAsFixed(0)})',
                              );

                            case ScoreInterpretation
                                .overallWeight:
                              return Text(
                                'Overall weighting (x / ${widget.overallWeight.toStringAsFixed(0)})',
                              );

                            case ScoreInterpretation
                                .custom:
                              return const Text(
                                'Custom marks',
                              );

                            case ScoreInterpretation
                                .ambiguous:
                              return const Text(
                                'Ambiguous',
                              );
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Normalised score: '
                            '${_interpretation!.percentage.toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            Text(
              'ScholarMind will automatically recognise whether this is entered as a percentage, coursework weighting, overall weighting or custom marks.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),

      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
          ),
        ),

        FilledButton(
          onPressed:
          _interpretation == null
              ? null
              : () {

            if (_interpretation!
                .requiresConfirmation) {

              // Sprint 12
              return;
            }

            Navigator.pop(
              context,
            );
          },
          child: const Text(
            'Save',
          ),
        ),
      ],
    );
  }
}