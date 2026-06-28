import 'package:flutter/material.dart';
import '../screens/study_material_picker_screen.dart';
import '../domain/study_material_type.dart';

class StudyMaterialsCard extends StatelessWidget {
  const StudyMaterialsCard({super.key});

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
              subtitle: const Text('Tap to select'),
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
              subtitle: const Text('Tap to select'),
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