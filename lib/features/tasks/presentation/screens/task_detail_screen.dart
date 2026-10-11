import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/priority_badge.dart';
import '../../domain/models/task.dart';
import '../controllers/task_provider.dart';
import '../widgets/task_form_sheet.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final TaskProvider provider;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.provider,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TextEditingController _newSubtaskController = TextEditingController();

  @override
  void dispose() {
    _newSubtaskController.dispose();
    super.dispose();
  }

  void _handleAddSubtask() {
    final text = _newSubtaskController.text.trim();
    if (text.isNotEmpty) {
      widget.provider.addSubTask(widget.taskId, text);
      _newSubtaskController.clear();
    }
  }

  void _openEditSheet(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => TaskFormSheet(
        provider: widget.provider,
        taskToEdit: task,
      ),
    );
  }

  void _confirmDelete(Task task) async {
    final confirmed = await showDialog<bool>(
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
    );

    if (confirmed == true && mounted) {
      widget.provider.deleteTask(task.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to changes in provider
    final tasks = widget.provider.tasks;
    final taskIndex = tasks.indexWhere((t) => t.id == widget.taskId);

    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Task not found')),
      );
    }

    final task = tasks[taskIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Task',
            onPressed: () => _openEditSheet(task),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete Task',
            onPressed: () => _confirmDelete(task),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category & Priority Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: task.category.gradient),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(task.category.icon, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          task.category.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  PriorityBadge(priority: task.priority),
                  const Spacer(),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: task.isCompleted ? AppColors.success : AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                task.title,
                style: AppTypography.displaySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),

              // Description
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  task.description,
                  style: AppTypography.bodyLarge.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.6,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Schedule Info Card
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.schedule_rounded, color: AppColors.primaryLight),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deadline',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.dueDate != null
                              ? '${DateFormatter.formatDate(task.dueDate!)} (${DateFormatter.getRelativeDueDate(task.dueDate)})'
                              : 'No deadline assigned',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: task.isOverdue ? AppColors.error : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Subtasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Checklist (${task.completedSubtasksCount}/${task.totalSubtasksCount})',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (task.totalSubtasksCount > 0)
                    Text(
                      '${(task.subtasksProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: task.subtasksProgress == 1.0 ? AppColors.success : AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress bar
              if (task.totalSubtasksCount > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: task.subtasksProgress,
                    minHeight: 6,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      task.subtasksProgress == 1.0 ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Subtasks List
              if (task.subtasks.isNotEmpty) ...[
                ...task.subtasks.map((subtask) {
                  return GlassCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => widget.provider.toggleSubTask(task.id, subtask.id),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: subtask.isCompleted ? AppColors.success : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: subtask.isCompleted
                                    ? AppColors.success
                                    : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                                width: 1.5,
                              ),
                            ),
                            child: subtask.isCompleted
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            subtask.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                              color: subtask.isCompleted ? const Color(0xFF94A3B8) : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                          onPressed: () => widget.provider.removeSubTask(task.id, subtask.id),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              // Add Subtask on the Fly
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newSubtaskController,
                      onSubmitted: (_) => _handleAddSubtask(),
                      decoration: const InputDecoration(
                        hintText: 'Add another step...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _handleAddSubtask,
                    icon: const Icon(Icons.add, size: 18),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tags Section
              if (task.tags.isNotEmpty) ...[
                Text(
                  'Tags',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: task.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
              ],

              // Complete / Re-open Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.provider.toggleTaskCompletion(task.id);
                  },
                  icon: Icon(
                    task.isCompleted ? Icons.replay_rounded : Icons.check_circle_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    task.isCompleted ? 'Mark as In Progress' : 'Mark as Completed',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: task.isCompleted ? AppColors.warning : AppColors.success,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
