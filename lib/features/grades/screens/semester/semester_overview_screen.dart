import 'package:flutter/material.dart';

import '../../widgets/current/current_section.dart';
import '../../widgets/history/history_section.dart';

class SemesterOverviewScreen extends StatelessWidget {
  const SemesterOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurrentSection(),
          HistorySection(),
        ],
      ),
    );
  }
}