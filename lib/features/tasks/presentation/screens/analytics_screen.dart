import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/models/task_category.dart';
import '../controllers/task_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weeklyTrend = provider.weeklyCompletedTrend;
    final maxInTrend = weeklyTrend.reduce((curr, next) => curr > next ? curr : next);
    final effectiveMax = maxInTrend == 0 ? 1 : maxInTrend;

    final categoryCounts = provider.categoryCounts;
    final totalTasks = provider.totalTasksCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Productivity Insights',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Scorecard Matrix (2x2 Grid)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Completed Tasks',
                      value: '${provider.completedTasksCount}',
                      subtitle: 'of ${provider.totalTasksCount} total',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Completion Rate',
                      value: '${(provider.completionRate * 100).toInt()}%',
                      subtitle: 'Overall efficiency',
                      icon: Icons.pie_chart_rounded,
                      color: AppColors.primaryLight,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Current Streak',
                      value: '${provider.currentStreak} Days',
                      subtitle: 'Daily consistency',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.warning,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Overdue Tasks',
                      value: '${provider.overdueTasksCount}',
                      subtitle: provider.overdueTasksCount == 0 ? 'All clear!' : 'Needs attention',
                      icon: Icons.warning_amber_rounded,
                      color: provider.overdueTasksCount > 0 ? AppColors.error : AppColors.success,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 7-Day Completion Velocity Chart Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '7-Day Velocity',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Tasks completed per day',
                              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Active Week',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Bar Chart
                    SizedBox(
                      height: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (index) {
                          final count = weeklyTrend[index];
                          final heightPct = (count / effectiveMax).clamp(0.12, 1.0);
                          final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final dayLabel = daysOfWeek[index];
                          final isToday = index == 6;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isToday ? AppColors.primaryLight : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 26,
                                height: 95 * heightPct,
                                decoration: BoxDecoration(
                                  gradient: isToday
                                      ? AppColors.primaryGradient
                                      : LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            AppColors.primary.withValues(alpha: 0.3),
                                            AppColors.primary.withValues(alpha: 0.6),
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dayLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                                  color: isToday
                                      ? (isDark ? Colors.white : AppColors.primaryDark)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Distribution Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category Breakdown',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Task distribution across focus areas',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 20),
                    ...TaskCategory.defaultCategories.map((cat) {
                      final count = categoryCounts[cat] ?? 0;
                      final ratio = totalTasks == 0 ? 0.0 : count / totalTasks;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(cat.icon, size: 14, color: cat.color),
                                const SizedBox(width: 8),
                                Text(
                                  cat.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                Text(
                                  '$count tasks (${(ratio * 100).toInt()}%)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pro Tip Motivational Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withValues(alpha: 0.15),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryLight, size: 26),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apex Tip: Two-Minute Rule',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'If a task takes less than two minutes, complete it immediately. For larger projects, break them into bite-sized subtasks!',
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.4),
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
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }
}
