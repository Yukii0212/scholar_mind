import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import '../../providers/course/course_provider.dart';
import '../../providers/grading/grading_provider.dart';
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
    ref.watch(
      hasGradingStructureProvider(
        widget.course.id,
      ),
    );

    final liveCourse = ref.watch(
      courseProvider(
        widget.course.id,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: liveCourse.when(
          loading: () => Text(widget.course.name),
          error: (_, __) => Text(widget.course.name),
          data: (course) => Text(course.name),
        ),
      ),
      body: CourseDetailBody(
        key: _bodyKey,
        course: widget.course,
      ),
    );
  }
}