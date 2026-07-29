import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/swipe_cards/swipe_card_item.dart';
import '../../../../core/widgets/swipe_cards/swipe_cards.dart';
import '../../../help/widgets/help_menu_button.dart';
import '../../data/models/course_model.dart';
import '../../help/course_analytics_preview_provider.dart';
import '../../help/course_detail_help_topics.dart';
import '../../providers/course/course_provider.dart';
import '../../providers/grading/grading_provider.dart';
import '../../widgets/course/course_prediction_card.dart';
import '../../widgets/course/course_standing_card.dart';
import '../../widgets/course/course_targets_card.dart';

/// A deliberate, separate destination from `CourseDetailScreen` (reached
/// via its "Analytics" action, left via the back button) rather than a
/// mode toggled within it — see that screen's doc comment for why.
class CourseAnalyticsScreen extends ConsumerStatefulWidget {
  const CourseAnalyticsScreen({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  ConsumerState<CourseAnalyticsScreen> createState() =>
      CourseAnalyticsScreenState();
}

class CourseAnalyticsScreenState extends ConsumerState<CourseAnalyticsScreen> {
  final GlobalKey<SwipeCardsState> _swipeCardsKey =
      GlobalKey<SwipeCardsState>();

  /// Lets the help tutorial bring a specific analytics page into view
  /// before spotlighting something inside it, then waits for that page's
  /// crossfade to finish so the anchor is fully settled before it gets
  /// measured. No tab switch needed anymore — this screen only exists
  /// once you're already here.
  Future<void> revealAnalyticsItem(int page) async {
    _swipeCardsKey.currentState?.showPage(page);
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    final liveCourse = ref.watch(courseProvider(widget.course.id));
    final repository = ref.watch(gradingComponentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: liveCourse.when(
          loading: () => Text(widget.course.name),
          error: (_, __) => Text(widget.course.name),
          data: (value) => Text(value.name),
        ),
        actions: [
          HelpMenuButton(
            pageId: 'course-analytics',
            topics: courseDetailHelpTopics(
              revealAnalyticsItem: revealAnalyticsItem,
              setProjectedScorePreview: (value) => ref
                  .read(courseAnalyticsProjectedScorePreviewProvider.notifier)
                  .state = value,
              setRequiredScorePreview: (value) => ref
                  .read(courseAnalyticsRequiredScorePreviewProvider.notifier)
                  .state = value,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder(
          stream: repository.watchCourseComponents(widget.course.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final components = snapshot.data!;

            return liveCourse.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
              data: (course) => SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: SwipeCards(
                  key: _swipeCardsKey,
                  items: [
                    SwipeCardItem(
                      title: 'Overview',
                      icon: Icons.analytics_outlined,
                      child: CurrentStandingCard(
                        course: course,
                        courseId: course.id,
                        components: components,
                      ),
                    ),
                    SwipeCardItem(
                      title: 'Targets',
                      icon: Icons.flag_outlined,
                      child: CourseTargetsCard(course: course),
                    ),
                    SwipeCardItem(
                      title: 'Predictions',
                      icon: Icons.insights_outlined,
                      child: CoursePredictionCard(course: course),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
