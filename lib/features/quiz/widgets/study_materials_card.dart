import 'package:flutter/material.dart';

import '../domain/processing_status.dart';
import '../services/study_material_preprocessor.dart';

class StudyMaterialsCard extends StatefulWidget {
  const StudyMaterialsCard({
    super.key,
    required this.selectedLectureNotes,
    required this.selectedPastYearQuestions,
    required this.processedLectureNotes,
    required this.processedPastYearQuestions,
    required this.lectureNotesStatus,
    required this.pastYearQuestionsStatus,
    required this.onLectureNotesTap,
    required this.onPastYearQuestionsTap,
    required this.onManageLectureNotesTap,
    required this.onManagePastYearQuestionsTap,
  });

  final Set<String> selectedLectureNotes;
  final Set<String> selectedPastYearQuestions;

  final List<ProcessedStudyMaterial>
  processedLectureNotes;

  final List<ProcessedStudyMaterial>
  processedPastYearQuestions;

  final ProcessingStatus lectureNotesStatus;
  final ProcessingStatus pastYearQuestionsStatus;

  final VoidCallback onLectureNotesTap;
  final VoidCallback onPastYearQuestionsTap;
  final VoidCallback onManageLectureNotesTap;
  final VoidCallback onManagePastYearQuestionsTap;

  @override
  State<StudyMaterialsCard> createState() =>
      _StudyMaterialsCardState();
}

class _StudyMaterialsCardState
    extends State<StudyMaterialsCard>
    with TickerProviderStateMixin {
  bool _showAllLectureNotes = false;

  bool _showAllPastYearQuestions = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Study Materials',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),

            const SizedBox(height: 20),

            _buildSection(
              context: context,
              title: 'Lecture Notes',
              icon: Icons.description_outlined,
              selectedCount: widget.selectedLectureNotes.length,
              processed: widget.processedLectureNotes,
              status: widget.lectureNotesStatus,
              expanded: _showAllLectureNotes,
              onExpandChanged: () {
                setState(() {
                  _showAllLectureNotes =
                  !_showAllLectureNotes;
                });
              },
              onTap: widget.onLectureNotesTap,
              onManageTap:
              widget.onManageLectureNotesTap,
            ),

            const Divider(),

            _buildSection(
              context: context,
              title: 'Past Year Questions',
              icon: Icons.quiz_outlined,
              selectedCount: widget.selectedPastYearQuestions.length,
              processed: widget.processedPastYearQuestions,
              status: widget.pastYearQuestionsStatus,
              expanded: _showAllPastYearQuestions,
              onExpandChanged: () {
                setState(() {
                  _showAllPastYearQuestions =
                  !_showAllPastYearQuestions;
                });
              },
              onTap: widget.onPastYearQuestionsTap,
              onManageTap:
              widget.onManagePastYearQuestionsTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int selectedCount,
    required List<
        ProcessedStudyMaterial>
    processed,
    required ProcessingStatus status,
    required bool expanded,
    required VoidCallback
    onExpandChanged,
    required VoidCallback onTap,
    required VoidCallback onManageTap,
  }) {
    final visible = expanded
        ? processed
        : processed.take(3).toList();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            child: Icon(icon),
          ),
          title: Text(title),
          subtitle: Text(
            selectedCount == 0
                ? 'Tap to select'
                : '$selectedCount selected',
          ),
          trailing:
          const Icon(Icons.chevron_right),
          onTap: onTap,
        ),

        if (status ==
            ProcessingStatus.processing)
          const Padding(
            padding:
            EdgeInsets.only(bottom: 8),
            child: LinearProgressIndicator(),
          ),

        AnimatedSize(
          duration: const Duration(
            milliseconds: 250,
          ),
          child: Column(
            children: [
              for (final item in visible)
                ListTile(
                  dense: true,
                  visualDensity:
                  VisualDensity.compact,
                  leading: const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.green,
                  ),
                  title: Text(
                    item.note.name,
                    maxLines: 1,
                    overflow: TextOverflow
                        .ellipsis,
                  ),
                ),

              if (processed.length > 3)
                Align(
                  alignment:
                  Alignment.centerLeft,
                  child: TextButton(
                    onPressed:
                    onExpandChanged,
                    child: Text(
                      expanded
                          ? 'Show less'
                          : 'Show all (${processed.length})',
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (selectedCount > 0)
          Align(
            alignment:
            Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onManageTap,
              icon: const Icon(
                Icons.edit_outlined,
              ),
              label: const Text(
                'Review Selection',
              ),
            ),
          ),
      ],
    );
  }
}