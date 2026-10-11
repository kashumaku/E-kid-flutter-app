import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/task_provider.dart';

class ProgressSummaryCard extends StatelessWidget {
  final TaskProvider provider;

  const ProgressSummaryCard({
    super.key,
    required this.provider,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completionPct = (provider.completionRate * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E1B4B), // Deep indigo
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFEEF2FF),
                  const Color(0xFFE0E7FF),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Streak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()}, Ready to conquer today?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Today\'s Focus',
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              // Streak Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.currentStreak}d Streak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Middle: Circular Gauge and Stats Breakdown
          Row(
            children: [
              // Radial Progress Gauge
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: provider.completionRate,
                      strokeWidth: 8,
                      backgroundColor: isDark
                          ? const Color(0xFF312E81)
                          : const Color(0xFFC7D2FE),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      '$completionPct%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Breakdown counters
              Expanded(
                child: Row(
                  children: [
                    _buildStatCol(
                      context,
                      label: 'Pending',
                      value: '${provider.pendingTasksCount}',
                      icon: Icons.timelapse_rounded,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 14),
                    _buildStatCol(
                      context,
                      label: 'Completed',
                      value: '${provider.completedTasksCount}',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 14),
                    _buildStatCol(
                      context,
                      label: 'Overdue',
                      value: '${provider.overdueTasksCount}',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
