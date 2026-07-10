import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import '../../providers/grading/grading_structure_controller.dart';
import 'course_information_card.dart';
import '../../providers/grading/grading_provider.dart';
import '../grading/component/grading_component_summary_list.dart';

class CourseDetailBody extends ConsumerStatefulWidget {
  const CourseDetailBody({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  ConsumerState<CourseDetailBody> createState() =>
      CourseDetailBodyState();
}

class CourseDetailBodyState
    extends ConsumerState<CourseDetailBody> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    await ref
        .read(
      gradingStructureControllerProvider,
    )
        .loadCourse(widget.course.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          CourseInformationCard(
            course: widget.course,
          ),

          const SizedBox(height: 24),

          const SizedBox(height: 32),

          Expanded(
            child: Consumer(
              builder: (
                  context,
                  ref,
                  _,
                  ) {
                final components =
                ref.watch(
                  gradingComponentRepositoryProvider,
                );

                return StreamBuilder(
                  stream: components
                      .watchCourseComponents(
                    widget.course.id,
                  ),
                  builder: (
                      context,
                      snapshot,
                      ) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child:
                        CircularProgressIndicator(),
                      );
                    }

                    final data =
                    snapshot.data!;

                    if (data.isEmpty) {
                      return const _EmptyGradingStructure();
                    }

                    return SingleChildScrollView(
                      child:
                      GradingComponentSummaryList(
                        components: data,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGradingStructure
    extends StatelessWidget {
  const _EmptyGradingStructure();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(height: 24),

            Text(
              'No grading structure yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'Create a grading structure or use one of your saved templates to begin tracking this course.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}