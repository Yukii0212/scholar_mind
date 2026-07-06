import 'package:flutter/material.dart';

import '../../data/models/semester_model.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.semester,
  });

  final SemesterModel semester;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(semester.name),
      ),
    );
  }
}