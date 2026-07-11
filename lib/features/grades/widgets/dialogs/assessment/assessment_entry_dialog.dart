import 'package:flutter/material.dart';

import '../../../domain/assessment/score_interpretation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/assessment_entry_model.dart';
import '../../../domain/assessment/assessment_type.dart';
import '../../../providers/assessment/assessment_provider.dart';
import '../../../domain/assessment/score_interpreter.dart';

class AssessmentEntryDialog
    extends ConsumerStatefulWidget {
  const AssessmentEntryDialog({
    super.key,
    required this.title,
    required this.courseId,
    required this.componentId,
    required this.componentWeight,
    required this.overallWeight,
    required this.isPrediction,
  });

  final String title;
  final String courseId;
  final String componentId;

  final double componentWeight;
  final double overallWeight;

  final bool isPrediction;

  @override
  ConsumerState<
      AssessmentEntryDialog> createState() =>
      _AssessmentEntryDialogState();
}

class _AssessmentEntryDialogState
    extends ConsumerState<
        AssessmentEntryDialog> {

  final _scoreController =
  TextEditingController();

  final _denominatorController =
  TextEditingController(
    text: '100',
  );

  ScoreInterpretationResult?
  _interpretation;

  ScoreInterpretation?
  _selectedInterpretation;

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

      if (!_interpretation!
          .requiresConfirmation) {
        _selectedInterpretation =
            _interpretation!
                .interpretation;
      }
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [

                          Icon(
                            _interpretation!.isValid
                                ? Icons.info_outline
                                : Icons.error_outline,
                            color: _interpretation!.isValid
                                ? Theme.of(context)
                                .colorScheme
                                .primary
                                : Theme.of(context)
                                .colorScheme
                                .error,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              _interpretation!.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _interpretation!.description,
                      ),

                      const SizedBox(height: 12),

                      if (_interpretation!.isValid)
                        Text(
                          'Equivalent percentage: '
                              '${_interpretation!.percentage.toStringAsFixed(1)}%',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),

                      if (_interpretation!
                          .requiresConfirmation) ...[

                        const SizedBox(height: 16),

                        Text(
                          'Help ScholarMind understand your score',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall,
                        ),

                        const SizedBox(height: 8),

                        RadioListTile<ScoreInterpretation>(
                          value:
                          ScoreInterpretation.componentWeight,
                          groupValue:
                          _selectedInterpretation,
                          contentPadding:
                          EdgeInsets.zero,
                          title: const Text(
                            'Coursework weighting',
                          ),
                          subtitle: Text(
                            'Treat this as a score out of '
                                '${widget.componentWeight.toStringAsFixed(0)}.',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedInterpretation =
                                  value;
                            });
                          },
                        ),

                        RadioListTile<ScoreInterpretation>(
                          value:
                          ScoreInterpretation.overallWeight,
                          groupValue:
                          _selectedInterpretation,
                          contentPadding:
                          EdgeInsets.zero,
                          title: const Text(
                            'Final grade weighting',
                          ),
                          subtitle: Text(
                            'Treat this as a score out of '
                                '${widget.overallWeight.toStringAsFixed(0)}.',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedInterpretation =
                                  value;
                            });
                          },
                        ),
                      ],

                      if (!_interpretation!.isValid)
                        Text(
                          _interpretation!.validationMessage!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .error,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            Text(
              'Enter the score exactly as your lecturer provided it. ScholarMind will recognise the format automatically.',
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
          _interpretation == null ||
              !_interpretation!.isValid ||
              (_interpretation!
                  .requiresConfirmation &&
                  _selectedInterpretation ==
                      null)
              ? null
              : () async {

            final now =
            DateTime.now();

            final repository = ref.read(
              assessmentRepositoryProvider,
            );

            final model =
            AssessmentEntryModel(
              id:
              '${widget.componentId}_${widget.isPrediction ? 'expected' : 'actual'}',
              courseId:
              widget.courseId,
              componentId:
              widget.componentId,
              type:
              widget.isPrediction
                  ? AssessmentType.expected
                  : AssessmentType.actual,
              score: double.parse(
                _scoreController.text,
              ),
              denominator:
              double.parse(
                _denominatorController.text,
              ),
              percentage:
              _interpretation!
                  .percentage,
              interpretation:
              _selectedInterpretation ??
                  _interpretation!
                      .interpretation,
              createdAt: now,
              updatedAt: now,
            );

            await repository.saveEntry(
              model,
            );

            if (context.mounted) {
              Navigator.pop(
                context,
              );
            }
          },
          child: const Text(
            'Save',
          ),
        ),
      ],
    );
  }
}