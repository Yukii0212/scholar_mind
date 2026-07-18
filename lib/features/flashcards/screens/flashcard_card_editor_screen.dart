import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/flashcard_models.dart';
import '../providers/flashcard_provider.dart';

class FlashcardCardEditorScreen extends ConsumerStatefulWidget {
  const FlashcardCardEditorScreen({
    super.key,
    required this.deck,
    this.card,
  });

  final FlashcardDeck deck;
  final Flashcard? card;

  @override
  ConsumerState<FlashcardCardEditorScreen> createState() =>
      _FlashcardCardEditorScreenState();
}

class _FlashcardCardEditorScreenState
    extends ConsumerState<FlashcardCardEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _frontController;
  late final TextEditingController _backController;
  late final TextEditingController _tagsController;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final card = widget.card;
    _frontController = TextEditingController(text: card?.front ?? '');
    _backController = TextEditingController(text: card?.back ?? '');
    _tagsController = TextEditingController(
      text: card?.tags.join(', ') ?? widget.deck.tags.join(', '),
    );
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.card != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Card' : 'Add Card'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save'),
          ),
          const Gap(8),
        ],
      ),
      body: ScholarScaffoldBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: ScholarPanel(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ScholarSectionHeader(
                          title: 'Flashcard Content',
                          subtitle: 'Markdown text is stored for both sides',
                        ),
                        const Gap(16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final narrow = constraints.maxWidth < 720;
                            final front = _SideField(
                              controller: _frontController,
                              label: 'Front / Question',
                              icon: Icons.help_outline_rounded,
                            );
                            final back = _SideField(
                              controller: _backController,
                              label: 'Back / Answer',
                              icon: Icons.lightbulb_outline_rounded,
                            );

                            if (narrow) {
                              return Column(
                                children: [
                                  front,
                                  const Gap(12),
                                  back,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: front),
                                const Gap(12),
                                Expanded(child: back),
                              ],
                            );
                          },
                        ),
                        const Gap(12),
                        TextFormField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            labelText: 'Tags',
                            helperText: 'Separate tags with commas',
                            prefixIcon: Icon(Icons.sell_outlined),
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
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(authStateProvider).valueOrNull?.uid;
    if (userId == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(flashcardRepositoryProvider).saveCard(
            userId: userId,
            deckId: widget.deck.id,
            cardId: widget.card?.id,
            front: _frontController.text.trim(),
            back: _backController.text.trim(),
            tags: _tagsController.text.split(','),
            frontImageUrl: widget.card?.frontImageUrl,
            backImageUrl: widget.card?.backImageUrl,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SideField extends StatelessWidget {
  const _SideField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: 8,
      maxLines: 12,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return 'This side cannot be empty';
        }
        return null;
      },
    );
  }
}
