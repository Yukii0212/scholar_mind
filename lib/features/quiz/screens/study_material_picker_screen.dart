import 'package:flutter/material.dart';
import '../domain/study_material_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/domain/library_folder.dart';
import '../../notes/providers/library_provider.dart';

class StudyMaterialPickerScreen extends ConsumerWidget {
  const StudyMaterialPickerScreen({
    super.key,
    required this.type,
  });

  final StudyMaterialType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (type) {
            StudyMaterialType.lectureNotes => 'Lecture Notes',
            StudyMaterialType.pastYearQuestions => 'Past Year Questions',
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ref.watch(
              childFoldersProvider(
                LibraryFolder.rootId,
              ),
            ).when(
              data: (folders) {
                if (folders.isEmpty) {
                  return const Center(
                    child: Text(
                      'No folders found.',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(folder.name),
                        trailing: folder.isFavorite
                            ? const Icon(Icons.star)
                            : const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text(error.toString()),
              ),
            ),
          ),

          SafeArea(
            top: false,
            minimum: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Select at least one note'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}