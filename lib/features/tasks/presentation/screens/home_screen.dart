import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/task_provider.dart';
import '../widgets/hero_task_banner.dart';
import '../widgets/today_task_card.dart';
import '../widgets/upcoming_task_card.dart';
import '../widgets/task_form_sheet.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openCreateSheet(BuildContext context, TaskProvider provider) {
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

    // Filter today's tasks and upcoming tasks
    final todayTasks = tasks.take(2).toList();
    final upcomingTasks = tasks.length > 2 ? tasks.skip(2).toList() : tasks;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
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
                            const Text(
                              'Linda C. Ng',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E232E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateString,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Search Button in rounded container
                    GestureDetector(
                      onTap: () => _openCreateSheet(context, provider),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF64748B),
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
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Section 1: "Today's Task" + "See All"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today\'s Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E232E),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
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
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (todayTasks.isNotEmpty) ...[
                        TodayTaskCard(
                          task: todayTasks[0],
                          backgroundColor: AppColors.cardCyan,
                          icon: Icons.grid_view_rounded,
                          progress: 0.40,
                          onTap: () => _openTaskDetails(context, provider, todayTasks[0].id),
                        ),
                        const SizedBox(width: 14),
                      ],
                      if (todayTasks.length > 1) ...[
                        TodayTaskCard(
                          task: todayTasks[1],
                          backgroundColor: AppColors.cardCoral,
                          icon: Icons.groups_rounded,
                          progress: 0.60,
                          onTap: () => _openTaskDetails(context, provider, todayTasks[1].id),
                        ),
                        const SizedBox(width: 14),
                      ],
                      // Additional fallback cards if tasks exist
                      ...tasks.skip(2).take(1).map((t) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: TodayTaskCard(
                            task: t,
                            backgroundColor: AppColors.cardPurple,
                            icon: Icons.palette_rounded,
                            progress: 0.75,
                            onTap: () => _openTaskDetails(context, provider, t.id),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Section 2: "Upcoming Task" + "See All"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E232E),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
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
