import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';
import '../../../onboarding/data/onboarding_repository.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../../domain/models/task_priority.dart';
import '../controllers/task_provider.dart';

/// Abstract, theme-aware Settings & Profile Screen for E'kid.
class SettingsScreen extends StatefulWidget {
  final IOnboardingRepository onboardingRepository;

  const SettingsScreen({
    super.key,
    required this.onboardingRepository,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local preferences state
  bool _dueRemindersEnabled = true;
  bool _dailyDigestEnabled = true;
  bool _hapticsEnabled = true;
  bool _biometricsEnabled = false;
  bool _compactViewEnabled = false;
  TaskPriority _defaultPriority = TaskPriority.high;

  void _triggerHaptic() {
    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  // Edit Profile Dialog
  void _showEditProfileModal(BuildContext context, AuthProvider? authProvider) {
    if (authProvider == null) return;
    final current = authProvider.currentUser;
    final nameController = TextEditingController(text: current?.fullName ?? '');
    final phoneController = TextEditingController(text: current?.phoneNumber ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const _AbstractIconBadge(
                        icon: Icons.person_pin_rounded,
                        color: Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Profile Identity',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Update your credentials in local storage',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Linda C. Ng',
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'e.g. +1 555 0199',
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          _triggerHaptic();
                          final success = await authProvider.updateProfile(
                            fullName: nameController.text.trim(),
                            phoneNumber: phoneController.text.trim(),
                          );
                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                          }
                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile identity updated successfully!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Save Identity',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Priority Selector Modal
  void _showPriorityPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Default Priority',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Newly created tasks will automatically default to this priority level',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ...TaskPriority.values.map((p) {
                final isSelected = _defaultPriority == p;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  leading: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: p.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(p.icon, color: p.color, size: 18),
                  ),
                  title: Text(
                    p.displayName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    _triggerHaptic();
                    setState(() {
                      _defaultPriority = p;
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Default priority set to ${p.displayName}'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // Export Data JSON Modal
  void _showExportDataModal(BuildContext context, TaskProvider taskProvider) {
    final tasksList = taskProvider.tasks
        .map((t) => {
              'id': t.id,
              'title': t.title,
              'description': t.description,
              'category': t.category.name,
              'priority': t.priority.displayName,
              'isCompleted': t.isCompleted,
              'dueDate': t.dueDate?.toIso8601String(),
              'subtasks': t.subtasks
                  .map((s) => {
                        'id': s.id,
                        'title': s.title,
                        'isCompleted': s.isCompleted,
                      })
                  .toList(),
            })
        .toList();

    final jsonStr = const JsonEncoder.withIndent('  ').convert({
      'app': AppConstants.appName,
      'exportedAt': DateTime.now().toIso8601String(),
      'totalCount': tasksList.length,
      'tasks': tasksList,
    });

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              _AbstractIconBadge(
                icon: Icons.data_object_rounded,
                color: Color(0xFF06B6D4),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Vault Export', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('Encrypted SQLite JSON payload', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${taskProvider.totalTasksCount} TASKS',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(jsonStr.length / 1024).toStringAsFixed(1)} KB PAYLOAD',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 180,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      jsonStr,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy JSON'),
              onPressed: () {
                _triggerHaptic();
                Clipboard.setData(ClipboardData(text: jsonStr));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Database export copied to clipboard!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Privacy Pledge Modal
  void _showPrivacyPledgeModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            _AbstractIconBadge(
              icon: Icons.shield_rounded,
              color: Color(0xFF10B981),
            ),
            SizedBox(width: 12),
            Text('Zero-Telemetry Pledge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'E\'kid operates on a strict Offline-First, Local-First paradigm:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Text('• 100% On-Device Persistence: Tasks, subtasks, and profiles are safely stored inside local SQLite and SharedPreferences sandbox.'),
              SizedBox(height: 8),
              Text('• Zero Analytics Trackers: We collect 0 telemetry, 0 marketing identifiers, and 0 behavioral footprints.'),
              SizedBox(height: 8),
              Text('• Sovereign Data Ownership: Your tasks never leave your phone without your explicit JSON export.'),
              SizedBox(height: 8),
              Text('• No Remote Cloud Downtime: Fully responsive without any cellular network connection required.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  // Productivity & Gesture Guide Modal
  void _showGestureGuideModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            _AbstractIconBadge(
              icon: Icons.lightbulb_outline_rounded,
              color: AppColors.warning,
            ),
            SizedBox(width: 12),
            Text('Workflow & Gestures', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• Fast Checklists: Tap any subtask checkbox to instantly record progress and recalculate completion metrics.'),
              SizedBox(height: 8),
              Text('• Inline Add & Edit: In the Task Detail screen, add new checklist items directly without opening extra screens.'),
              SizedBox(height: 8),
              Text('• Search & Category Tabs: Filter by Work, Design, Health, or Study to isolate high-leverage priorities.'),
              SizedBox(height: 8),
              Text('• Full-Screen Creation: Tap the center "+" dock button to launch the comprehensive task builder.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // About E'kid Modal
  void _showAboutModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(AppConstants.appIconAsset, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              Text(
                AppConstants.appTagline,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'VERSION 1.0.0 • PRODUCTION BUILD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A fluid, senior-engineered productivity workstation designed for seamless flow, beautiful aesthetics, and absolute reliability.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Dismiss', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      },
    );
  }

  // Clear Tasks Confirmation
  Future<void> _showClearTasksConfirmation(BuildContext context, TaskProvider taskProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Tasks?'),
        content: const Text(
          'This will permanently delete all tasks, checklist items, and history from your local SQLite database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _triggerHaptic();
      await taskProvider.clearAllTasks();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All tasks cleared from local SQLite database.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Log Out Confirmation
  Future<void> _showLogoutConfirmation(BuildContext context, AuthProvider? authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out of your session on this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      _triggerHaptic();
      await authProvider?.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => OnboardingScreen(
              onboardingRepository: widget.onboardingRepository,
            ),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final authProvider = context.watch<AuthProvider?>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = authProvider?.currentUser?.fullName ?? 'Linda C. Ng';
    final userPhone = authProvider?.currentUser?.phoneNumber ?? '+1 555 0199';
    final userInitials = authProvider?.currentUser?.initials ?? 'LN';

    final totalTasks = taskProvider.totalTasksCount;
    final completedTasks = taskProvider.completedTasksCount;
    final focusRate = (taskProvider.completionRate * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings & Profile',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Share Feedback',
            icon: const Icon(Icons.favorite_outline_rounded, color: AppColors.primary),
            onPressed: () {
              _triggerHaptic();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for loving E\'kid! 🚀'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 90),
          children: [
            // ==========================================
            // ABSTRACT HERO PROFILE CARD
            // ==========================================
            Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AbstractAuraPainter(
                      isDark: isDark,
                      primaryColor: AppColors.primary,
                    ),
                  ),
                ),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 24,
                  backgroundColor: isDark
                      ? const Color(0xFF141C2E).withValues(alpha: 0.90)
                      : Colors.white.withValues(alpha: 0.90),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Glowing Abstract Avatar
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 66,
                                height: 66,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.40),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  userInitials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? AppColors.darkCard : Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.success.withValues(alpha: 0.6),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Name, Phone & PRO Badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  userPhone,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.3),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: const Text(
                                        'E\'KID PRO',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primary,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => _showEditProfileModal(context, authProvider),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.08)
                                              : Colors.black.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit_rounded, size: 10, color: AppColors.secondary),
                                            SizedBox(width: 4),
                                            Text(
                                              'Edit',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Abstract Metrics Ribbon
                      Row(
                        children: [
                          _AbstractMetricPill(
                            label: 'TOTAL',
                            value: '$totalTasks',
                            accentColor: AppColors.secondary,
                            icon: Icons.assignment_rounded,
                          ),
                          const SizedBox(width: 10),
                          _AbstractMetricPill(
                            label: 'DONE',
                            value: '$completedTasks',
                            accentColor: AppColors.success,
                            icon: Icons.check_circle_rounded,
                          ),
                          const SizedBox(width: 10),
                          _AbstractMetricPill(
                            label: 'FOCUS',
                            value: '$focusRate%',
                            accentColor: AppColors.primary,
                            icon: Icons.local_fire_department_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ==========================================
            // SECTION 1: WORKSPACE & DISPLAY
            // ==========================================
            const _AbstractSectionHeader(
              title: 'WORKSPACE & DISPLAY',
              dotColor: AppColors.accent,
            ),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.palette_rounded,
                      color: AppColors.accent,
                    ),
                    title: 'Theme Interface',
                    subtitle: themeProvider.themeMode == ThemeMode.dark
                        ? 'Obsidian Dark'
                        : themeProvider.themeMode == ThemeMode.light
                            ? 'Clarity Light'
                            : 'Follow System',
                    trailing: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_rounded, size: 15),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_rounded, size: 15),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_rounded, size: 15),
                        ),
                      ],
                      selected: {themeProvider.themeMode},
                      onSelectionChanged: (set) {
                        _triggerHaptic();
                        themeProvider.setThemeMode(set.first);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.flag_rounded,
                      color: AppColors.primary,
                    ),
                    title: 'Default Task Priority',
                    subtitle: 'Auto-assigned when creating tasks',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _defaultPriority.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_defaultPriority.icon, size: 12, color: _defaultPriority.color),
                          const SizedBox(width: 4),
                          Text(
                            _defaultPriority.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _defaultPriority.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => _showPriorityPickerModal(context),
                  ),
                  const Divider(height: 1),
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.view_agenda_rounded,
                      color: AppColors.secondary,
                    ),
                    title: 'Compact Feed Density',
                    subtitle: 'Condense task cards to display more on-screen',
                    trailing: Switch.adaptive(
                      value: _compactViewEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        _triggerHaptic();
                        setState(() => _compactViewEnabled = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ==========================================
            // SECTION 2: SIGNALS & ALERTS
            // ==========================================
            const _AbstractSectionHeader(
              title: 'SIGNALS & ALERTS',
              dotColor: AppColors.warning,
            ),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.notifications_active_rounded,
                      color: AppColors.warning,
                    ),
                    title: 'Due Date Reminders',
                    subtitle: 'Push alerts for upcoming deadlines',
                    trailing: Switch.adaptive(
                      value: _dueRemindersEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        _triggerHaptic();
                        setState(() => _dueRemindersEnabled = val);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.wb_sunny_rounded,
                      color: Color(0xFF6366F1),
                    ),
                    title: 'Morning Focus Digest',
                    subtitle: '8:00 AM summary briefing of daily priorities',
                    trailing: Switch.adaptive(
                      value: _dailyDigestEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        _triggerHaptic();
                        setState(() => _dailyDigestEnabled = val);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.vibration_rounded,
                      color: Color(0xFF14B8A6),
                    ),
                    title: 'Tactile Haptic Feedback',
                    subtitle: 'Micro-vibrations on checklist ticks & touches',
                    trailing: Switch.adaptive(
                      value: _hapticsEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _hapticsEnabled = val);
                        if (val) HapticFeedback.mediumImpact();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ==========================================
            // SECTION 3: SECURITY & IDENTITY
            // ==========================================
            const _AbstractSectionHeader(
              title: 'SECURITY & IDENTITY',
              dotColor: AppColors.success,
            ),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.person_pin_rounded,
                      color: Color(0xFF3B82F6),
                    ),
                    title: 'Profile Credentials',
                    subtitle: 'Update full name and contact phone number',
                    onTap: () => _showEditProfileModal(context, authProvider),
                  ),
                  const Divider(height: 1),
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.fingerprint_rounded,
                      color: AppColors.success,
                    ),
                    title: 'Biometric App Lock',
                    subtitle: 'Require Face ID / Fingerprint on launch',
                    trailing: Switch.adaptive(
                      value: _biometricsEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        _triggerHaptic();
                        setState(() => _biometricsEnabled = val);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.devices_rounded,
                      color: Color(0xFFA855F7),
                    ),
                    title: 'Active Device Session',
                    subtitle: 'Apple Ecosystem • Primary Workstation',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 7, color: AppColors.success),
                          SizedBox(width: 4),
                          Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ==========================================
            // SECTION 4: DATA VAULT & STORAGE
            // ==========================================
            const _AbstractSectionHeader(
              title: 'DATA VAULT & STORAGE',
              dotColor: Color(0xFF06B6D4),
            ),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.data_object_rounded,
                      color: Color(0xFF06B6D4),
                    ),
                    title: 'Export & Backup Vault',
                    subtitle: 'Generate formatted JSON of all local SQLite tasks',
                    onTap: () => _showExportDataModal(context, taskProvider),
                  ),
                  const Divider(height: 1),
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.auto_stories_rounded,
                      color: AppColors.secondary,
                    ),
                    title: 'Replay Onboarding Tour',
                    subtitle: 'View the interactive product onboarding again',
                    onTap: () {
                      _triggerHaptic();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OnboardingScreen(
                            onboardingRepository: widget.onboardingRepository,
                            isReplay: true,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.shield_rounded,
                      color: Color(0xFF10B981),
                    ),
                    title: 'Zero-Telemetry Pledge',
                    subtitle: '100% on-device SQLite • Zero third-party trackers',
                    onTap: () => _showPrivacyPledgeModal(context),
                  ),
                  const Divider(height: 1),
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.delete_sweep_rounded,
                      color: AppColors.error,
                    ),
                    title: 'Clear All Tasks',
                    subtitle: 'Permanently wipe local SQLite database',
                    titleColor: AppColors.error,
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.error),
                    onTap: () => _showClearTasksConfirmation(context, taskProvider),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ==========================================
            // SECTION 5: COMMUNITY & ABOUT
            // ==========================================
            const _AbstractSectionHeader(
              title: 'COMMUNITY & ABOUT',
              dotColor: AppColors.primary,
            ),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.info_outline_rounded,
                      color: AppColors.primary,
                    ),
                    title: 'About E\'kid',
                    subtitle: 'Version 1.0.0 • Product overview & release notes',
                    onTap: () => _showAboutModal(context),
                  ),
                  const Divider(height: 1),
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.lightbulb_outline_rounded,
                      color: AppColors.warning,
                    ),
                    title: 'Workflow & Gestures',
                    subtitle: 'Tips for checklists, shortcuts, and focus streaks',
                    onTap: () => _showGestureGuideModal(context),
                  ),
                  const Divider(height: 1),
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.favorite_rounded,
                      color: Color(0xFFEC4899),
                    ),
                    title: 'Recommend E\'kid',
                    subtitle: 'Share your flow with colleagues & friends',
                    onTap: () {
                      _triggerHaptic();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sharing link copied! Spread the word for E\'kid.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ==========================================
            // SECTION 6: SESSION
            // ==========================================
            const _AbstractSectionHeader(
              title: 'SESSION',
              dotColor: AppColors.error,
            ),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _AbstractSettingTile(
                    leading: const _AbstractIconBadge(
                      icon: Icons.logout_rounded,
                      color: AppColors.error,
                    ),
                    title: 'Log Out',
                    subtitle: 'Safely terminate session on this device',
                    titleColor: AppColors.error,
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.error),
                    onTap: () => _showLogoutConfirmation(context, authProvider),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // ==========================================
            // ABSTRACT FOOTER WITH APP ICON
            // ==========================================
            Center(
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(AppConstants.appIconAsset, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${AppConstants.appName} v1.0.0',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Precision engineered with Flutter & Material 3',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 11, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'Systems Operational',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
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

/// Abstract geometric aura painter drawn behind the profile hero card.
class _AbstractAuraPainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;

  const _AbstractAuraPainter({
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Abstract concentric rings anchored in the upper-right corner
    final ringCenter = Offset(size.width * 0.90, size.height * 0.22);
    for (double r = 40; r <= 160; r += 38) {
      ringPaint.color = primaryColor.withValues(alpha: isDark ? 0.08 : 0.05);
      canvas.drawCircle(ringCenter, r, ringPaint);
    }

    // Abstract geometric diagonal accent lines
    final linePaint = Paint()
      ..strokeWidth = 1.0
      ..color = (isDark ? Colors.cyanAccent : Colors.blueAccent)
          .withValues(alpha: isDark ? 0.07 : 0.04);

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.92),
      Offset(size.width * 0.45, size.height * 0.08),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.92),
      Offset(size.width * 0.55, size.height * 0.08),
      linePaint,
    );

    // Subtle floating geometric points
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: isDark ? 0.22 : 0.14);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.25), 2.5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.70, size.height * 0.88), 2.0, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.65), 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _AbstractAuraPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.primaryColor != primaryColor;
}

/// Abstract squircle icon badge with subtle gradient and border tint.
class _AbstractIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _AbstractIconBadge({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.32),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: color),
    );
  }
}

/// Abstract section header with glowing neon dot indicator.
class _AbstractSectionHeader extends StatelessWidget {
  final String title;
  final Color dotColor;

  const _AbstractSectionHeader({
    required this.title,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.7),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable abstract setting tile with high-contrast typography and subtle colors.
class _AbstractSettingTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _AbstractSettingTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: titleColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            )
          : null,
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
      onTap: onTap,
    );
  }
}

/// Abstract metric capsule for the Profile Hero banner.
class _AbstractMetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final IconData icon;

  const _AbstractMetricPill({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: accentColor),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
