import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/flashcard_models.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/study_swipe_card_item.dart';
import '../widgets/study_swipe_cards.dart';

enum _SelfEvaluation {
  knewIt,
  almost,
  didntKnow,
  skipped,
}

class FlashcardStudySessionScreen extends ConsumerStatefulWidget {
  const FlashcardStudySessionScreen({
    super.key,
    required this.deck,
    required this.cards,
  });

  final FlashcardDeck deck;
  final List<Flashcard> cards;

  @override
  ConsumerState<FlashcardStudySessionScreen> createState() =>
      _FlashcardStudySessionScreenState();
}

class _FlashcardStudySessionScreenState
    extends ConsumerState<FlashcardStudySessionScreen> {
  late final List<Flashcard> _queue;
  var _currentIndex = 0;
  var _showAnswer = false;
  var _reviewed = 0;
  var _known = 0;
  var _needsReview = 0;
  var _completed = false;

  @override
  void initState() {
    super.initState();
    _queue = [...widget.cards];
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final current = _completed || _queue.isEmpty ? null : _queue[_currentIndex];
    final progress = _queue.isEmpty
        ? 0.0
        : (_reviewed / _queue.length).clamp(0, 1).toDouble();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Study Session'),
        actions: [
          TextButton.icon(
            onPressed: _finish,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Exit'),
          ),
          const Gap(8),
        ],
      ),
      body: ScholarScaffoldBackground(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: _completed
                    ? _CompletionPanel(
                        reviewed: _reviewed,
                        known: _known,
                        needsReview: _needsReview,
                      )
                    : Column(
                        children: [
                          ScholarPanel(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                      ),
                                    ),
                                    const Gap(12),
                                    Text(
                                      '${_currentIndex + 1}/${_queue.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Gap(16),
                          if (current != null)
                            Expanded(
                              child: StudySwipeCards(
                                enabled: !_showAnswer,
                                item: StudySwipeCardItem(
                                  title: 'Flashcard',
                                  icon: Icons.style_rounded,
                                  onSkipped: () =>
                                      _evaluate(_SelfEvaluation.skipped),
                                  child: GestureDetector(
                                    onTap: () => setState(
                                          () => _showAnswer = !_showAnswer,
                                    ),
                                    child: ScholarPanel(
                                      padding: const EdgeInsets.all(22),
                                      child: Center(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              _Pill(
                                                _showAnswer
                                                    ? 'Answer'
                                                    : 'Question',
                                                _showAnswer
                                                    ? palette.success
                                                    : palette.brandEnd,
                                              ),
                                              const Gap(22),
                                              Text(
                                                _showAnswer
                                                    ? current.back
                                                    : current.front,
                                                textAlign:
                                                TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                  fontWeight:
                                                  FontWeight.w800,
                                                ),
                                              ),
                                              const Gap(22),
                                              Text(
                                                _showAnswer
                                                    ? 'Choose how well you knew it'
                                                    : 'Tap to reveal • Swipe to skip',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                  color:
                                                  palette.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const Gap(16),
                          if (_showAnswer)
                            _EvaluationPanel(onSelected: _evaluate),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _evaluate(_SelfEvaluation evaluation) {
    final current = _queue[_currentIndex];

    if (evaluation == _SelfEvaluation.skipped) {
      _queue.add(current);

      if (_currentIndex >= _queue.length - 1) {
        setState(() => _completed = true);
        _recordSession();
        return;
      }

      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });

      return;
    }

    _reviewed++;

    if (evaluation == _SelfEvaluation.knewIt) {
      _known++;
    } else {
      _needsReview++;
      _queue.add(current);
    }

    if (_currentIndex >= _queue.length - 1) {
      setState(() => _completed = true);
      _recordSession();
      return;
    }

    setState(() {
      _currentIndex++;
      _showAnswer = false;
    });
  }

  Future<void> _finish() async {
    if (!_completed && _reviewed > 0) {
      await _recordSession();
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _recordSession() async {
    final userId = ref.read(authStateProvider).valueOrNull?.uid;
    if (userId == null) return;
    await ref.read(flashcardRepositoryProvider).recordSession(
          userId: userId,
          deckId: widget.deck.id,
          reviewed: _reviewed,
          known: _known,
          needsReview: _needsReview,
        );
  }
}

class _EvaluationPanel extends StatelessWidget {
  const _EvaluationPanel({required this.onSelected});

  final ValueChanged<_SelfEvaluation> onSelected;

  @override
  Widget build(BuildContext context) {
    return ScholarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How well did you know this?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: _EvaluationButton(
                  label: 'I Knew It',
                  icon: Icons.sentiment_very_satisfied_rounded,
                  color: context.scholarPalette.success,
                  onTap: () => onSelected(_SelfEvaluation.knewIt),
                ),
              ),
              const Gap(10),
              Expanded(
                child: _EvaluationButton(
                  label: 'Almost',
                  icon: Icons.sentiment_neutral_rounded,
                  color: context.scholarPalette.warning,
                  onTap: () => onSelected(_SelfEvaluation.almost),
                ),
              ),
              const Gap(10),
              Expanded(
                child: _EvaluationButton(
                  label: "Didn't Know",
                  icon: Icons.sentiment_dissatisfied_rounded,
                  color: Theme.of(context).colorScheme.error,
                  onTap: () => onSelected(_SelfEvaluation.didntKnow),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvaluationButton extends StatelessWidget {
  const _EvaluationButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class _CompletionPanel extends StatelessWidget {
  const _CompletionPanel({
    required this.reviewed,
    required this.known,
    required this.needsReview,
  });

  final int reviewed;
  final int known;
  final int needsReview;

  @override
  Widget build(BuildContext context) {
    return ScholarPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ScholarIconBadge(icon: Icons.check_circle_outline, size: 62),
          const Gap(14),
          Text(
            'Session Complete',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Gap(12),
          Text('$reviewed reviewed - $known known - $needsReview need review'),
          const Gap(18),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
