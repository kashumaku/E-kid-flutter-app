import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../onboarding/data/onboarding_repository.dart';
import '../tasks/presentation/controllers/task_provider.dart';
import '../tasks/presentation/screens/analytics_screen.dart';
import '../tasks/presentation/screens/calendar_screen.dart';
import '../tasks/presentation/screens/home_screen.dart';
import '../tasks/presentation/screens/settings_screen.dart';
import '../tasks/presentation/widgets/task_form_sheet.dart';

class MainNavScaffold extends StatefulWidget {
  final int initialIndex;

  const MainNavScaffold({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _openCreateTaskSheet() {
    final provider = context.read<TaskProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => TaskFormSheet(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onboardingRepo = context.read<IOnboardingRepository>();

    final screens = [
      const HomeScreen(),
      const CalendarScreen(),
      const AnalyticsScreen(),
      SettingsScreen(onboardingRepository: onboardingRepo),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateTaskSheet,
        elevation: 6,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primaryLight),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primaryLight),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded, color: AppColors.primaryLight),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryLight),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
