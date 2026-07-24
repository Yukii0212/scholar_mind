import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/flashcard_models.dart';
import '../providers/flashcard_provider.dart';
import 'flashcard_deck_detail_screen.dart';
import 'flashcard_deck_editor_screen.dart';
import 'generate_flashcards_screen.dart';

class FlashcardLibraryScreen extends ConsumerWidget {
  const FlashcardLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(flashcardDecksProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: const _FlashcardSpeedDial(),
      body: SafeArea(
        top: false,
        child: decksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Unable to load decks: $error')),
          data: (decks) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScholarSectionHeader(
                      title: 'Flashcards',
                      subtitle:
                          'Create decks, revise quickly, and generate from notes',
                    ),
                    const Gap(16),
                    _LibrarySummary(decks: decks),
                    const Gap(16),
                    if (decks.isEmpty)
                      const _EmptyDecks()
                    else
                      Column(
                        children: [
                          for (final deck in decks) ...[
                            _DeckTile(deck: deck),
                            if (deck != decks.last) const Gap(12),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlashcardSpeedDial extends StatelessWidget {
  const _FlashcardSpeedDial();

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 12,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.auto_awesome_rounded),
          label: 'Generate Flashcards',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const GenerateFlashcardsScreen(),
              ),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.style_outlined),
          label: 'Create Deck',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const FlashcardDeckEditorScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LibrarySummary extends StatelessWidget {
  const _LibrarySummary({required this.decks});

  final List<FlashcardDeck> decks;

  @override
  Widget build(BuildContext context) {
    final totalCards = decks.fold<int>(0, (sum, deck) => sum + deck.cardCount);
    final aiDecks = decks
        .where((deck) =>
            deck.generationMethod == FlashcardGenerationMethod.aiGenerated)
        .length;

    return ScholarPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final tiles = [
            _SummaryTile(Icons.layers_outlined, 'Decks', '${decks.length}'),
            _SummaryTile(Icons.style_outlined, 'Cards', '$totalCards'),
            _SummaryTile(Icons.auto_awesome_outlined, 'AI Decks', '$aiDecks'),
          ];

          if (narrow) {
            return Column(
              children: [
                for (final tile in tiles) ...[
                  tile,
                  if (tile != tiles.last) const Gap(10),
                ],
              ],
            );
          }

          return Row(
            children: [
              for (final tile in tiles) ...[
                Expanded(child: tile),
                if (tile != tiles.last) const Gap(10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.panelStrong.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.stroke),
      ),
      child: Row(
        children: [
          ScholarIconBadge(icon: icon, size: 38),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeckTile extends ConsumerWidget {
  const _DeckTile({required this.deck});

  final FlashcardDeck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.scholarPalette;
    final userId = ref.watch(authStateProvider).valueOrNull?.uid;

    return ScholarPanel(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => FlashcardDeckDetailScreen(deck: deck)),
      ),
      child: Row(
        children: [
          ScholarIconBadge(
            icon: deck.generationMethod == FlashcardGenerationMethod.aiGenerated
                ? Icons.auto_awesome_rounded
                : Icons.edit_outlined,
            size: 52,
            color:
                deck.generationMethod == FlashcardGenerationMethod.aiGenerated
                    ? palette.brandStart
                    : palette.brandEnd,
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deck.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Gap(6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _DeckPill('${deck.cardCount} cards'),
                    _DeckPill(deck.generationMethod.label),
                    for (final tag in deck.tags.take(2)) _DeckPill(tag),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FlashcardDeckEditorScreen(deck: deck),
                  ),
                );
              }
              if (value == 'delete' && userId != null) {
                await ref.read(flashcardRepositoryProvider).deleteDeck(
                      userId: userId,
                      deckId: deck.id,
                    );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeckPill extends StatelessWidget {
  const _DeckPill(this.label);

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

class _EmptyDecks extends StatelessWidget {
  const _EmptyDecks();

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return ScholarPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const ScholarIconBadge(icon: Icons.style_outlined, size: 58),
          const Gap(14),
          Text(
            'No flashcard decks yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Gap(6),
          Text(
            'Create a manual deck or generate one from your notes.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: palette.textMuted),
          ),
        ],
      ),
    );
  }
}
