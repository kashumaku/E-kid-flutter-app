import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';
import '../controllers/task_provider.dart';
import '../widgets/hero_task_banner.dart';
import '../widgets/today_task_card.dart';
import '../widgets/upcoming_task_card.dart';
import 'task_form_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openCreateScreen(BuildContext context, TaskProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(provider: provider),
      ),
    );
  }

  void _openTaskDetails(BuildContext context, TaskProvider provider, String taskId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          taskId: taskId,
          provider: provider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;
    final now = DateTime.now();
    final dateString = DateFormat('d MMM yyyy').format(now);

    final authProvider = context.watch<AuthProvider?>();
    final userName = authProvider?.currentUser?.fullName ?? 'Linda C. Ng';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1E232E);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8);
    final iconBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFE0F7FA);
    final searchIconColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    // Filter today's tasks and upcoming tasks
    final todayTasks = tasks.take(2).toList();
    final upcomingTasks = tasks.length > 2 ? tasks.skip(2).toList() : tasks;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadTasks(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar: User Profile Avatar + Linda C. Ng + Search Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFDE68A),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.face_rounded,
                              color: Color(0xFF92400E),
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateString,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Search Button in rounded container
                    GestureDetector(
                      onTap: () => _openCreateScreen(context, provider),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: searchIconColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Hero Banner: "Your daily task almost done!"
                HeroTaskBannerCard(
                  provider: provider,
                  onViewTask: () {
                    if (tasks.isNotEmpty) {
                      _openTaskDetails(context, provider, tasks.first.id);
                    } else {
                      _openCreateScreen(context, provider);
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Section 1: "Today's Task" + "See All"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: textSecondary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'See All',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Horizontal list of Today's Task Cards (Cyan & Coral)
                if (todayTasks.isEmpty)
                  GestureDetector(
                    onTap: () => _openCreateScreen(context, provider),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tasks for today yet',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap here or the + button to create one',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: todayTasks.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final task = todayTasks[index];
                        final colors = [AppColors.cardCyan, AppColors.cardCoral, AppColors.cardPurple];
                        final icons = [Icons.grid_view_rounded, Icons.groups_rounded, Icons.palette_rounded];
                        final bg = colors[index % colors.length];
                        final icon = icons[index % icons.length];
                        final progress = task.subtasks.isEmpty
                            ? (task.isCompleted ? 1.0 : 0.0)
                            : task.subtasksProgress;

                        return TodayTaskCard(
                          task: task,
                          backgroundColor: bg,
                          icon: icon,
                          progress: progress,
                          onTap: () => _openTaskDetails(context, provider, task.id),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 28),

                // Section 2: "Upcoming Task" + "See All"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: textSecondary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'See All',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Vertical List of Upcoming Task Cards
                if (upcomingTasks.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      'No upcoming tasks scheduled',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  ...upcomingTasks.map((task) {
                    return UpcomingTaskCard(
                      task: task,
                      onTap: () => _openTaskDetails(context, provider, task.id),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
