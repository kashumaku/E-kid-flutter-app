import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/priority_badge.dart';
import '../../domain/models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = task.isOverdue;
    final isDueToday = task.isDueToday;

    Color dueDateColor;
    if (task.isCompleted) {
      dueDateColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    } else if (isOverdue) {
      dueDateColor = AppColors.error;
    } else if (isDueToday) {
      dueDateColor = AppColors.warning;
    } else {
      dueDateColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    }

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggleComplete();
          return false; // Don't remove from widget tree; let state update
        } else {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Task?'),
              content: Text('Are you sure you want to delete "${task.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ) ?? false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'Toggle Done',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
      child: GlassCard(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: task.isCompleted ? 0.65 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Category tag, Priority badge, Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated Circular Checkbox
                  GestureDetector(
                    onTap: onToggleComplete,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: task.isCompleted
                            ? const LinearGradient(
                                colors: [AppColors.success, Color(0xFF34D399)],
                              )
                            : null,
                        color: task.isCompleted ? null : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted
                              ? AppColors.success
                              : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                          width: 2,
                        ),
                        boxShadow: task.isCompleted
                            ? [
                                BoxShadow(
                                  color: AppColors.success.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Category pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: task.category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(task.category.icon, size: 12, color: task.category.color),
                        const SizedBox(width: 4),
                        Text(
                          task.category.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: task.category.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Priority badge
                  PriorityBadge(priority: task.priority),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  task.title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    decorationThickness: 2,
                    decorationColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ),

              // Description (if present)
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],

              // Subtasks Progress Bar (if any subtasks exist)
              if (task.subtasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Checklist: ${task.completedSubtasksCount}/${task.totalSubtasksCount}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                          Text(
                            '${(task.subtasksProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: task.subtasksProgress == 1.0
                                  ? AppColors.success
                                  : AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: task.subtasksProgress,
                          minHeight: 5,
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            task.subtasksProgress == 1.0 ? AppColors.success : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Bottom Info: Due Date & Tags
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Row(
                  children: [
                    // Due Date
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: dueDateColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.getRelativeDueDate(task.dueDate),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: dueDateColor,
                      ),
                    ),

                    if (task.tags.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: task.tags.map((tag) {
                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
