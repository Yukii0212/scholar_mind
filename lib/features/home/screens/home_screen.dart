import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_tasks/widgets/app_task_banner.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/models/scholar_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/background_sync_service.dart';
import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../../countdown/widgets/countdown_dashboard_card.dart';
import '../widgets/grades/semester_panel.dart';

import '../widgets/countdown/dashboard_countdown_carousel.dart';
import '../../grades/providers/semester/current_semester_provider.dart';
import '../../grades/providers/semester/semester_statistics_provider.dart';
import '../../notes/providers/library_provider.dart';
import '../../quiz/providers/quiz_library_provider.dart' as quiz_library;
import '../../study_streak/providers/study_streak_provider.dart';
import '../../study_streak/widgets/study_streak_dashboard_card.dart';

const _navRoutes = [
  '/home',
  '/notes',
  '/quiz',
  '/flashcards',
];

const _navItems = [
  _NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
  _NavItem(Icons.description_rounded, Icons.description_outlined, 'Notes'),
  _NavItem(Icons.quiz_rounded, Icons.quiz_outlined, 'Quiz'),
  _NavItem(Icons.style_rounded, Icons.style_outlined, 'Cards'),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final BackgroundSyncService _backgroundSync;

  int _locationToIndex(String location) {
    for (var i = 0; i < _navRoutes.length; i++) {
      if (location.startsWith(_navRoutes[i])) return i;
    }
    return -1;
  }

  @override
  void initState() {
    super.initState();

    _backgroundSync = BackgroundSyncService();
    _backgroundSync.start(ref.read(allUploadedNotesProvider.stream));
  }

  @override
  void dispose() {
    _backgroundSync.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _locationToIndex(location);
    final isWide = MediaQuery.sizeOf(context).width >= 860;
    final palette = context.scholarPalette;
    final user = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: isWide ? 24 : 8,
        leading: null,
        title: const ScholarBrand(compact: true),
        actions: [
          _UserAvatar(
            user: user,
            onTap: () => context.go('/profile'),
          ),
          const Gap(6),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            tooltip: 'Sign out',
          ),
          const Gap(8),
        ],
      ),
      body: ScholarScaffoldBackground(
        child: Column(
          children: [
            const AppTaskBanner(),
            Expanded(
              child: Row(
                children: [
                  if (isWide)
                    _DesktopRail(
                      selectedIndex: selectedIndex,
                      onSelected: (index) => context.go(_navRoutes[index]),
                    ),
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: palette.panel.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.stroke),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < _navItems.length; i++)
                      Expanded(
                        child: _MobileNavButton(
                          item: _navItems[i],
                          selected: i == selectedIndex,
                          onTap: () => context.go(_navRoutes[i]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(studyStreakRecorderProvider);
    final notes = ref.watch(allUploadedNotesProvider).valueOrNull ?? const [];
    final quizzes =
        ref.watch(quiz_library.activeQuizzesProvider).valueOrNull ?? const [];
    final semester = ref.watch(currentSemesterProvider).valueOrNull;
    final statistics = semester == null
        ? null
        : ref.watch(semesterStatisticsProvider(semester.id)).valueOrNull;
    final averageScore = _averageScore(statistics);
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, isWide ? 24 : 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardHero(
                  name: user?.displayName,
                  isWide: isWide,
                ),
                const Gap(16),
                _QuickAccessGrid(isWide: isWide),
                const Gap(16),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _TodayPanel(
                          noteCount: notes.length,
                          quizCount: quizzes.length,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        flex: 2,
                        child: SemesterPanel(
                          semesterName: semester?.name,
                          courseCount: statistics?.length ?? 0,
                          averageScore: averageScore,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _TodayPanel(
                        noteCount: notes.length,
                        quizCount: quizzes.length,
                      ),
                      const Gap(16),
                      SemesterPanel(
                        semesterName: semester?.name,
                        courseCount: statistics?.length ?? 0,
                        averageScore: averageScore,
                      ),
                    ],
                  ),
                const Gap(16),
                const _GenerateQuizBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static double? _averageScore(List<SemesterCoursePriority>? statistics) {
    if (statistics == null) {
      return null;
    }

    final scores = statistics
        .map((entry) => entry.summary.averageAssessmentScore)
        .whereType<double>()
        .toList();

    if (scores.isEmpty) {
      return null;
    }

    return scores.reduce((a, b) => a + b) / scores.length;
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.name,
    required this.isWide,
  });

  final String? name;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final hour = TimeOfDay.now().hour;
    final greeting = hour < 12
        ? 'Good morning,'
        : hour < 18
            ? 'Good afternoon,'
            : 'Good evening,';

    final header = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.textMuted,
                    ),
              ),
              const Gap(4),
              Text(
                _firstName(name),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const Gap(8),
              Text(
                'Keep your streak alive and your next deadline visible.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                    ),
              ),
            ],
          ),
        ),
        if (isWide) const ScholarIllustration(size: 118),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const Gap(16),
        if (isWide)
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: StudyStreakDashboardCard()),
              Gap(16),
              Expanded(
                child: DashboardCountdownCarousel(),
              ),
            ],
          )
        else
          const Column(
            children: [
              StudyStreakDashboardCard(),
              Gap(16),
              DashboardCountdownCarousel(),
              Gap(12),
            ],
          ),
      ],
    );
  }

  static String _firstName(String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return 'Scholar';
    return trimmed.split(RegExp(r'\s+')).first;
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    const actions = [
      _QuickAction('Notes', Icons.description_rounded, '/notes'),
      _QuickAction('Quiz', Icons.bolt_rounded, '/quiz'),
      _QuickAction('Grades', Icons.bar_chart_rounded, '/grades'),
      _QuickAction('Flashcards', Icons.style_rounded, '/flashcards'),
      _QuickAction('Share', Icons.ios_share_rounded, '/export'),
    ];

    return ScholarPanel(
      child: Column(
        children: [
          const ScholarSectionHeader(title: 'Quick Access'),
          const Gap(14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 4 : 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: isWide ? 2.35 : 1.42,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return ScholarPanel(
                padding: const EdgeInsets.all(12),
                onTap: () => context.go(action.route),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScholarIconBadge(icon: action.icon),
                    const Gap(10),
                    Text(
                      action.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodayPanel extends StatelessWidget {
  const _TodayPanel({
    required this.noteCount,
    required this.quizCount,
  });

  final int noteCount;
  final int quizCount;

  @override
  Widget build(BuildContext context) {
    return ScholarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScholarSectionHeader(
            title: 'Today',
            subtitle: 'A focused snapshot of your study space',
          ),
          const Gap(16),
          _TaskRow(
            icon: Icons.upload_file_outlined,
            title: 'Study materials ready',
            subtitle: '$noteCount notes available for review',
            priority: 'Library',
            onTap: () => context.go('/notes'),
          ),
          const Gap(10),
          _TaskRow(
            icon: Icons.auto_awesome_rounded,
            title: 'Quiz practice',
            subtitle: '$quizCount generated quizzes in progress',
            priority: 'AI',
            onTap: () => context.go('/quiz'),
          ),
          const Gap(10),
          _TaskRow(
            icon: Icons.trending_up_rounded,
            title: 'Grade check-in',
            subtitle: 'Review your current course targets',
            priority: 'Grades',
            onTap: () => context.go('/grades'),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String priority;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.panelStrong.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: palette.stroke.withValues(alpha: 0.72)),
          ),
          child: Row(
            children: [
              ScholarIconBadge(icon: icon, size: 34),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Gap(3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              _Tag(label: priority),
            ],
          ),
        ),
      ),
    );
  }
}



class _GenerateQuizBanner extends StatelessWidget {
  const _GenerateQuizBanner();

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.stroke),
        gradient: LinearGradient(
          colors: [
            palette.brandStart.withValues(alpha: 0.36),
            palette.panelStrong,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          const ScholarIconBadge(icon: Icons.auto_awesome_rounded),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generate AI Quiz',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  'Turn your notes into personalized practice.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                      ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => context.go('/quiz'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

class _DesktopRail extends StatelessWidget {
  const _DesktopRail({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      width: 104,
      margin: const EdgeInsets.fromLTRB(14, 8, 0, 16),
      decoration: BoxDecoration(
        color: palette.panel.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.stroke),
      ),
      child: Column(
        children: [
          const Gap(12),
          for (var i = 0; i < _navItems.length; i++)
            _RailButton(
              item: _navItems[i],
              selected: selectedIndex == i,
              onTap: () => onSelected(i),
            ),
          //const Spacer(),
          const _ThemeChooser(),
          const Gap(12),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? palette.brandStart.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                color: selected ? palette.brandEnd : palette.textMuted,
              ),
              const Gap(4),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? palette.brandEnd : palette.textMuted,
                      fontWeight: selected ? FontWeight.w700 : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileNavButton extends StatelessWidget {
  const _MobileNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected
              ? palette.brandStart.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.selectedIcon : item.icon,
              color: selected ? palette.brandEnd : palette.textMuted,
              size: 21,
            ),
            const Gap(3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? palette.brandEnd : palette.textMuted,
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeChooser extends ConsumerWidget {
  const _ThemeChooser();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);

    return PopupMenuButton<ScholarTheme>(
      tooltip: 'Theme',
      icon: const Icon(Icons.palette_outlined),
      onSelected: ref.read(themeProvider.notifier).setTheme,
      itemBuilder: (context) => [
        _themeItem(
          ScholarTheme.midnight,
          'Midnight',
          AppAssets.darkIcon,
          current,
        ),
        _themeItem(
          ScholarTheme.scholarBlue,
          'Scholar Blue',
          AppAssets.scholarBlueIcon,
          current,
        ),
        _themeItem(
          ScholarTheme.sakuraPink,
          'Sakura Pink',
          AppAssets.sakuraPinkIcon,
          current,
        ),
      ],
    );
  }

  PopupMenuItem<ScholarTheme> _themeItem(
    ScholarTheme theme,
    String label,
    String icon,
    ScholarTheme current,
  ) {
    return PopupMenuItem(
      value: theme,
      child: Row(
        children: [
          Image.asset(icon, width: 24, height: 24),
          const Gap(10),
          Expanded(child: Text(label)),
          if (theme == current) const Icon(Icons.check_rounded, size: 18),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.user,
    required this.onTap,
  });

  final User? user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final url = user?.photoURL;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: CircleAvatar(
        radius: 15,
        backgroundColor: context.scholarPalette.brandStart,
        backgroundImage: url == null ? null : NetworkImage(url),
        child: url == null
            ? Text(
                (user?.displayName?.trim().isNotEmpty ?? false)
                    ? user!.displayName!.trim()[0].toUpperCase()
                    : 'S',
                style: const TextStyle(fontWeight: FontWeight.w800),
              )
            : null,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.scholarPalette.brandStart.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.scholarPalette.brandEnd,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.selectedIcon, this.icon, this.label);

  final IconData selectedIcon;
  final IconData icon;
  final String label;
}

class _QuickAction {
  const _QuickAction(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
