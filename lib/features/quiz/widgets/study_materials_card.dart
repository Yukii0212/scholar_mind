import 'package:flutter/material.dart';

import '../domain/processing_status.dart';
import '../domain/study_material_type.dart';
import '../screens/study_material_picker_screen.dart';

class StudyMaterialsCard extends StatelessWidget {
  const StudyMaterialsCard({
    super.key,
    required this.selectedLectureNotes,
    required this.selectedPastYearQuestions,
    required this.lectureNotesStatus,
    required this.pastYearQuestionsStatus,
  });

  final Set<String> selectedLectureNotes;

  final Set<String> selectedPastYearQuestions;

  final ProcessingStatus lectureNotesStatus;

  final ProcessingStatus pastYearQuestionsStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Materials',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                child: Icon(Icons.description_outlined),
              ),
              title: const Text('Lecture Notes'),
              subtitle: Text(
                selectedLectureNotes.isEmpty
                    ? 'Tap to select'
                    : '${selectedLectureNotes.length} selected',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudyMaterialPickerScreen(
                      type: StudyMaterialType.lectureNotes,
                    ),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                child: Icon(Icons.quiz_outlined),
              ),
              title: const Text('Past Year Questions'),
              subtitle: Text(
                selectedPastYearQuestions.isEmpty
                    ? 'Tap to select'
                    : '${selectedPastYearQuestions.length} selected',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudyMaterialPickerScreen(
                      type: StudyMaterialType.pastYearQuestions,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select at least one lecture note or past year question.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}