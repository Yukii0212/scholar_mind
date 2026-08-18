import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/flashcard_models.dart';
import '../providers/flashcard_provider.dart';

class FlashcardSetEditorScreen extends ConsumerStatefulWidget {
  const FlashcardSetEditorScreen({
    super.key,
    this.flashcardSet,
  });

  final FlashcardSet? flashcardSet;

  @override
  ConsumerState<FlashcardSetEditorScreen> createState() =>
      _FlashcardSetEditorScreenState();
}

class _FlashcardSetEditorScreenState
    extends ConsumerState<FlashcardSetEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _tagsController;
  late final TextEditingController _sourceController;
  late final TextEditingController _descriptionController;
  late FlashcardGenerationMethod _method;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final flashcardSet = widget.flashcardSet;
    _nameController = TextEditingController(text: flashcardSet?.name ?? '');
    _tagsController =
        TextEditingController(text: flashcardSet?.tags.join(', ') ?? '');
    _sourceController =
        TextEditingController(text: flashcardSet?.sourceReference ?? '');
    _descriptionController =
        TextEditingController(text: flashcardSet?.description ?? '');
    _method = flashcardSet?.generationMethod ?? FlashcardGenerationMethod.manual;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagsController.dispose();
    _sourceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.flashcardSet != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Set' : 'Create Set'),
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
                constraints: const BoxConstraints(maxWidth: 900),
                child: ScholarPanel(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ScholarSectionHeader(
                          title: 'Set Details',
                          subtitle: 'Set how this flashcard set is organized',
                        ),
                        const Gap(16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Set name',
                            prefixIcon: Icon(Icons.style_outlined),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Enter a set name';
                            }
                            return null;
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
                        const Gap(16),
                        SegmentedButton<FlashcardGenerationMethod>(
                          segments: [
                            for (final method
                                in FlashcardGenerationMethod.values)
                              ButtonSegment(
                                value: method,
                                label: Text(method.label),
                                icon: Icon(
                                  method ==
                                          FlashcardGenerationMethod.aiGenerated
                                      ? Icons.auto_awesome_rounded
                                      : Icons.edit_outlined,
                                ),
                              ),
                          ],
                          selected: {_method},
                          onSelectionChanged: (value) =>
                              setState(() => _method = value.first),
                        ),
                        const Gap(16),
                        TextFormField(
                          controller: _sourceController,
                          decoration: const InputDecoration(
                            labelText: 'Source reference',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                        ),
                        const Gap(12),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.notes_outlined),
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
      await ref.read(flashcardRepositoryProvider).saveSet(
            userId: userId,
            setId: widget.flashcardSet?.id,
            name: _nameController.text.trim(),
            tags: _tagsController.text.split(','),
            generationMethod: _method,
            sourceReference: _emptyToNull(_sourceController.text),
            description: _emptyToNull(_descriptionController.text),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
