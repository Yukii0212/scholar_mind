import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'dart:math';

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
  // Cards missed (skipped/almost/didn't-know) only come back once the rest
  // of the *current* round has been gone through, not appended to an
  // ever-growing single queue — a card only ever waits behind the cards
  // still ahead of it in this round, never behind every other miss too.
  late List<Flashcard> _roundQueue;
  final List<Flashcard> _missedThisRound = [];
  var _roundNumber = 1;

  var _currentIndex = 0;
  var _showAnswer = false;
  var _reviewed = 0;
  var _known = 0;
  var _needsReview = 0;
  var _completed = false;

  // Progress is "how much of the whole deck is mastered", not "how far
  // through the current round" — stable across rounds instead of tracking
  // a denominator that used to grow every time a card was missed.
  final Set<String> _knownCardIds = {};
  final Set<int> _milestonesShown = {};
  late final int _totalCards;

  @override
  void initState() {
    super.initState();

    _totalCards = widget.cards.length;
    _roundQueue = [...widget.cards]..shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final current =
        _completed || _roundQueue.isEmpty ? null : _roundQueue[_currentIndex];
    final progress = _totalCards == 0
        ? 0.0
        : (_knownCardIds.length / _totalCards).clamp(0, 1).toDouble();

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
                        totalCards: _totalCards,
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
                                      '${(progress * 100).round()}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                                if (_roundNumber > 1) ...[
                                  const Gap(8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Round $_roundNumber • '
                                      '${_roundQueue.length} card'
                                      '${_roundQueue.length == 1 ? '' : 's'} '
                                      "you're still working on",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: palette.textMuted),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Gap(16),
                          if (current != null)
                            Expanded(
                              child: StudySwipeCards(
                                enabled: true,
                                hintText: _showAnswer
                                    ? 'Swipe right: I knew it  •  '
                                        "Swipe left: Didn't know it"
                                    : 'Swipe either way to skip',
                                item: StudySwipeCardItem(
                                  title: 'Flashcard',
                                  icon: Icons.style_rounded,
                                  onSwipeLeft: () => _evaluate(
                                    _showAnswer
                                        ? _SelfEvaluation.didntKnow
                                        : _SelfEvaluation.skipped,
                                  ),
                                  onSwipeRight: () => _evaluate(
                                    _showAnswer
                                        ? _SelfEvaluation.knewIt
                                        : _SelfEvaluation.skipped,
                                  ),
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
                                                    ? 'Choose how well you knew it, '
                                                        'or swipe'
                                                    : 'Tap to reveal • Swipe either '
                                                        'way to skip',
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
    final current = _roundQueue[_currentIndex];

    if (evaluation == _SelfEvaluation.skipped) {
      _missedThisRound.add(current);
      _advance();
      return;
    }

    _reviewed++;

    if (evaluation == _SelfEvaluation.knewIt) {
      _known++;
      _knownCardIds.add(current.id);
    } else {
      _needsReview++;
      _missedThisRound.add(current);
    }

    _advance();
  }

  /// Moves to the next card in the current round, or — if the round just
  /// ran out — either finishes the session (nothing was missed) or starts
  /// a new round made up of just what was missed. A card only ever comes
  /// back after the rest of *this* round, never behind everything else.
  void _advance() {
    if (_currentIndex < _roundQueue.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });

      _maybeShowMilestone();
      return;
    }

    if (_missedThisRound.isEmpty) {
      setState(() => _completed = true);
      _recordSession();
      return;
    }

    setState(() {
      _roundQueue = [..._missedThisRound]..shuffle(Random());
      _missedThisRound.clear();
      _currentIndex = 0;
      _showAnswer = false;
      _roundNumber++;
    });

    _maybeShowMilestone();
  }

  void _maybeShowMilestone() {
    if (_totalCards == 0) return;

    final percent = (_knownCardIds.length / _totalCards * 100).round();

    for (final threshold in const [25, 50, 75]) {
      if (percent >= threshold && _milestonesShown.add(threshold)) {
        _showMilestoneToast(threshold);
      }
    }
  }

  void _showMilestoneToast(int threshold) {
    final message = switch (threshold) {
      25 => "Quarter of the way there — keep going!",
      50 => "Halfway there — you've got this.",
      75 => 'Almost done — final stretch!',
      _ => null,
    };

    if (message == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
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
    required this.totalCards,
  });

  final int reviewed;
  final int known;
  final int needsReview;
  final int totalCards;

  int get _masteryPercent =>
      totalCards == 0 ? 0 : ((known / totalCards) * 100).round();

  (String, String) get _headline {
    final percent = _masteryPercent;

    if (percent >= 100) {
      return ('Deck mastered!', "Every card in this deck — you knew it all.");
    }

    if (percent >= 75) {
      return ('Great work!', "You're close to mastering this deck.");
    }

    if (percent >= 50) {
      return ('Solid session!', 'Over half the deck is sticking.');
    }

    return ('Nice start!', 'Keep at it — it gets easier each round.');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final (headline, subtitle) = _headline;

    return ScholarPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ScholarIconBadge(icon: Icons.emoji_events_outlined, size: 62),
          const Gap(14),
          Text(
            headline,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Gap(6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.textMuted,
                ),
          ),
          const Gap(20),
          Text(
            '$_masteryPercent%',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: palette.brandEnd,
                ),
          ),
          Text(
            'mastered',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: palette.textMuted,
                ),
          ),
          const Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(
                icon: Icons.check_circle_outline,
                label: '$known known',
                color: palette.success,
              ),
              const Gap(12),
              _StatChip(
                icon: Icons.refresh_rounded,
                label: '$needsReview to revisit',
                color: palette.warning,
              ),
            ],
          ),
          const Gap(20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const Gap(6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
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
