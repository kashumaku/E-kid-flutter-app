import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../onboarding/data/onboarding_repository.dart';
import '../tasks/presentation/controllers/task_provider.dart';
import '../tasks/presentation/screens/analytics_screen.dart';
import '../tasks/presentation/screens/calendar_screen.dart';
import '../tasks/presentation/screens/home_screen.dart';
import '../tasks/presentation/screens/settings_screen.dart';
import '../tasks/presentation/screens/task_form_screen.dart';

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

  void _openCreateTaskScreen() {
    final provider = context.read<TaskProvider>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(provider: provider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingRepo = context.read<IOnboardingRepository>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      const HomeScreen(),
      const CalendarScreen(),
      const AnalyticsScreen(),
      SettingsScreen(onboardingRepository: onboardingRepo),
    ];

    return Scaffold(
      extendBody: true, // Allows content to flow behind the floating dock
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: IndexedStack(
        index: _currentIndex > 3 ? 0 : _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          height: 70,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.14),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Home Tab
              _buildFancyNavItem(
                index: 0,
                icon: Icons.home_rounded,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isSelected: _currentIndex == 0,
              ),

              // 2. Calendar Tab
              _buildFancyNavItem(
                index: 1,
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month_rounded,
                label: 'Schedule',
                isSelected: _currentIndex == 1,
              ),

              // 3. Center Elevated Floating Cyan Plus Action Button
              _buildCenterActionButton(),

              // 4. Analytics Tab (Insights & Notifications)
              _buildFancyNavItem(
                index: 2,
                icon: Icons.insights_outlined,
                activeIcon: Icons.insights_rounded,
                label: 'Insights',
                isSelected: _currentIndex == 2,
              ),

              // 5. Settings / Profile Tab
              _buildFancyNavItem(
                index: 3,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: 'Profile',
                isSelected: _currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterActionButton() {
    return GestureDetector(
      onTap: _openCreateTaskScreen,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildFancyNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
