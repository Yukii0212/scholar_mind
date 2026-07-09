import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import '../../widgets/course/course_detail_body.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  ConsumerState<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState
    extends ConsumerState<CourseDetailScreen> {
  final GlobalKey<CourseDetailBodyState>
  _bodyKey =
  GlobalKey<CourseDetailBodyState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.name),
        actions: [
          IconButton(
            onPressed: () {
              _bodyKey.currentState?.save();
            },
            icon: const Icon(
              Icons.save_outlined,
            ),
          ),
        ],
      ),
      body: CourseDetailBody(
        key: _bodyKey,
        course: widget.course,
      ),
    );
  }
}