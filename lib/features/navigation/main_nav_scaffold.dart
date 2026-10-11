import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../onboarding/data/onboarding_repository.dart';
import '../tasks/presentation/controllers/task_provider.dart';
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => TaskFormSheet(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingRepo = context.read<IOnboardingRepository>();

    final screens = [
      const HomeScreen(),
      const CalendarScreen(),
      SettingsScreen(onboardingRepository: onboardingRepo),
    ];

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: IndexedStack(
        index: _currentIndex > 2 ? 0 : _currentIndex,
        children: screens,
      ),
      // Floating Cyan Plus button in the center matching mockup
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 52,
        height: 52,
        margin: const EdgeInsets.only(top: 14),
        child: FloatingActionButton(
          onPressed: _openCreateTaskSheet,
          elevation: 4,
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add_rounded,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
      // Bottom Navigation Bar with 5 slots matching mockup
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tab 1: Home
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              isSelected: _currentIndex == 0,
            ),

            // Tab 2: Calendar
            _buildNavItem(
              index: 1,
              icon: Icons.calendar_month_outlined,
              isSelected: _currentIndex == 1,
            ),

            // Spacer for center Floating Button
            const SizedBox(width: 48),

            // Tab 3: Notifications / Analytics
            _buildNavItem(
              index: 1, // Opens calendar / notifications view
              icon: Icons.notifications_none_rounded,
              isSelected: false,
            ),

            // Tab 4: Settings
            _buildNavItem(
              index: 2,
              icon: Icons.settings_outlined,
              isSelected: _currentIndex == 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
