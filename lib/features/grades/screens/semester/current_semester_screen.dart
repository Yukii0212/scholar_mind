import 'package:flutter/material.dart';

import '../../widgets/semester/current_semester_section.dart';

class CurrentSemesterScreen extends StatelessWidget {
  const CurrentSemesterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: CurrentSemesterSection(),
    );
  }
}