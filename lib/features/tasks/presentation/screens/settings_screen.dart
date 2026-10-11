import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../onboarding/data/onboarding_repository.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../controllers/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  final IOnboardingRepository onboardingRepository;

  const SettingsScreen({
    super.key,
    required this.onboardingRepository,
  });

  void _showArchitectureInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.architecture_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Architecture Highlights'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ApexTask is engineered following Senior Flutter Architecture standards:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              SizedBox(height: 12),
              Text('• Clean & Feature-First Directory Structure: Modular boundaries between features (tasks, onboarding, navigation, core).'),
              SizedBox(height: 8),
              Text('• Pure Domain Layer: Immutable models, value objects, business calculation logic, zero UI coupling.'),
              SizedBox(height: 8),
              Text('• Repository Pattern & Abstraction: ITaskRepository, IOnboardingRepository with local SharedPreferences caching.'),
              SizedBox(height: 8),
              Text('• Reactive State Management: Provider + ChangeNotifier with separation of concerns and optimized rebuilds.'),
              SizedBox(height: 8),
              Text('• Curated Design System: Obsidian dark mode, fluid micro-interactions, responsive typography, and glassmorphism styling.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Awesome'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final taskProvider = context.read<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings & Profile',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
          children: [
            // Profile Card
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'KT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kassahun Tech',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Senior Productivity Master',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PRO ACCOUNT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Appearance Section
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode_rounded, color: AppColors.primaryLight),
                    title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      themeProvider.themeMode == ThemeMode.dark
                          ? 'Obsidian Dark'
                          : themeProvider.themeMode == ThemeMode.light
                              ? 'Clean Light'
                              : 'System Follower',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode, size: 16),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode, size: 16),
                        ),
                      ],
                      selected: {
                        themeProvider.themeMode == ThemeMode.light
                            ? ThemeMode.light
                            : ThemeMode.dark,
                      },
                      onSelectionChanged: (set) {
                        themeProvider.setThemeMode(set.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Experience Section
            const Text(
              'Experience & Data',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.auto_stories_rounded, color: AppColors.secondary),
                    title: const Text('Replay Onboarding Tour', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('View the interactive onboarding tour again', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OnboardingScreen(
                            onboardingRepository: onboardingRepository,
                            isReplay: true,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.restart_alt_rounded, color: AppColors.warning),
                    title: const Text('Reset to Sample Tasks', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Restore default showcase projects & subtasks', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reset Sample Data?'),
                          content: const Text('This will overwrite current tasks with default mock tasks.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await taskProvider.resetToSeed();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sample tasks restored!')),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.architecture_rounded, color: AppColors.primary),
                    title: const Text('System Architecture', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Learn about Clean Architecture in this app', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showArchitectureInfo(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // App Version Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '${AppConstants.appName} v1.0.0 (Senior Build)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Crafted with Flutter, Clean Architecture & Material 3',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
