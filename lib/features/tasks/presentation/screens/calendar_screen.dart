import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controllers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_sheet.dart';
import 'task_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(_today.year, _today.month, _today.day);
  }

  void _openCreateTask(BuildContext context, TaskProvider provider) {
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
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter tasks for the selected date
    final tasksForDay = provider.tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == _selectedDate.year &&
          task.dueDate!.month == _selectedDate.month &&
          task.dueDate!.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('MMMM yyyy').format(_selectedDate),
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: 'Jump to today',
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(_today.year, _today.month, _today.day);
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Horizontal Date Scroller (14 days: 3 days in past + 10 days in future)
            Container(
              height: 92,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 21,
                itemBuilder: (context, index) {
                  final date = _today.subtract(const Duration(days: 3)).add(Duration(days: index));
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  final isCurrentDay = date.year == _today.year &&
                      date.month == _today.month &&
                      date.day == _today.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime(date.year, date.month, date.day);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 58,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected
                            ? null
                            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isCurrentDay
                                  ? AppColors.primaryLight
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                          width: isCurrentDay ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date).toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white70
                                  : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                            ),
                          ),
                          if (isCurrentDay && !isSelected) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Date Header Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(_selectedDate),
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${tasksForDay.length} Scheduled',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tasks List
            Expanded(
              child: tasksForDay.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.event_available_rounded,
                      title: 'No tasks scheduled',
                      message: 'Enjoy your free time or schedule a task for this date.',
                      buttonLabel: 'Add Task to Schedule',
                      onAction: () => _openCreateTask(context, provider),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                      itemCount: tasksForDay.length,
                      itemBuilder: (context, index) {
                        final task = tasksForDay[index];
                        return TaskCard(
                          task: task,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(
                                  taskId: task.id,
                                  provider: provider,
                                ),
                              ),
                            );
                          },
                          onToggleComplete: () {
                            provider.toggleTaskCompletion(task.id);
                          },
                          onDelete: () {
                            provider.deleteTask(task.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
