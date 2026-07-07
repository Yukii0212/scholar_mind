import 'package:flutter/material.dart';

import '../../data/models/semester_model.dart';
import '../../widgets/semester/semester_detail_body.dart';
import '../../widgets/semester/semester_detail_popup_menu.dart';

class SemesterDetailScreen extends StatelessWidget {
  const SemesterDetailScreen({
    super.key,
    required this.semester,
  });

  final SemesterModel semester;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(semester.name),
          actions: [
            SemesterDetailPopupMenu(
              semester: semester,
            ),
          ],
        ),
      body: SemesterDetailBody(
        semester: semester,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Course creation coming soon.',
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}