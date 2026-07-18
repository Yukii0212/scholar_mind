import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/flashcard_models.dart';
import '../providers/flashcard_provider.dart';
import 'flashcard_card_editor_screen.dart';
import 'flashcard_deck_editor_screen.dart';
import 'flashcard_study_session_screen.dart';

class FlashcardDeckDetailScreen extends ConsumerWidget {
  const FlashcardDeckDetailScreen({
    super.key,
    required this.deck,
  });

  final FlashcardDeck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(flashcardsProvider(deck.id));
    final userId = ref.watch(authStateProvider).valueOrNull?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: userId == null
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FlashcardCardEditorScreen(deck: deck),
                  ),
                ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Card'),
      ),
      appBar: AppBar(
        title: Text(deck.name),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FlashcardDeckEditorScreen(deck: deck),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit deck',
          ),
        ],
      ),
      body: ScholarScaffoldBackground(
        child: SafeArea(
          top: false,
          child: cardsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('Unable to load cards: $error')),
            data: (cards) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DeckHero(deck: deck, cards: cards),
                      const Gap(16),
                      _ActionPanel(deck: deck, cards: cards),
                      const Gap(16),
                      ScholarPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScholarSectionHeader(
                              title: 'Cards (${cards.length})',
                              subtitle:
                                  'Front and back content remains editable',
                            ),
                            const Gap(14),
                            if (cards.isEmpty)
                              const Text('No cards yet.')
                            else
                              Column(
                                children: [
                                  for (var i = 0; i < cards.length; i++) ...[
                                    _CardRow(
                                      deck: deck,
                                      card: cards[i],
                                      index: i + 1,
                                    ),
                                    if (i != cards.length - 1) const Gap(10),
                                  ],
                                ],
                              ),
                          ],
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
    );
  }
}

class _DeckHero extends StatelessWidget {
  const _DeckHero({
    required this.deck,
    required this.cards,
  });

  final FlashcardDeck deck;
  final List<Flashcard> cards;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return ScholarPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          ScholarIconBadge(
            icon: deck.generationMethod == FlashcardGenerationMethod.aiGenerated
                ? Icons.auto_awesome_rounded
                : Icons.style_outlined,
            size: 64,
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deck.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill('${cards.length} cards'),
                    _Pill(deck.generationMethod.label),
                    if (deck.sourceReference != null)
                      _Pill(deck.sourceReference!),
                    for (final tag in deck.tags.take(3)) _Pill(tag),
                  ],
                ),
                if ((deck.description ?? '').trim().isNotEmpty) ...[
                  const Gap(12),
                  Text(
                    deck.description!.trim(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: palette.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.deck,
    required this.cards,
  });

  final FlashcardDeck deck;
  final List<Flashcard> cards;

  @override
  Widget build(BuildContext context) {
    return ScholarPanel(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              leading: const ScholarIconBadge(icon: Icons.play_arrow_rounded),
              title: const Text('Start Study Session'),
              subtitle: const Text('Review cards one by one'),
              enabled: cards.isNotEmpty,
              onTap: cards.isEmpty
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FlashcardStudySessionScreen(
                            deck: deck,
                            cards: cards,
                          ),
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardRow extends ConsumerWidget {
  const _CardRow({
    required this.deck,
    required this.card,
    required this.index,
  });

  final FlashcardDeck deck;
  final Flashcard card;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.scholarPalette;
    final userId = ref.watch(authStateProvider).valueOrNull?.uid;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.panelStrong.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.stroke),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: palette.brandStart.withValues(alpha: 0.32),
            child: Text('$index'),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.front,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Gap(6),
                Text(
                  card.back,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: palette.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FlashcardCardEditorScreen(
                  deck: deck,
                  card: card,
                ),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit card',
          ),
          IconButton(
            onPressed: userId == null
                ? null
                : () => ref.read(flashcardRepositoryProvider).deleteCard(
                      userId: userId,
                      deckId: deck.id,
                      cardId: card.id,
                    ),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete card',
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: palette.brandStart.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: palette.brandEnd,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
