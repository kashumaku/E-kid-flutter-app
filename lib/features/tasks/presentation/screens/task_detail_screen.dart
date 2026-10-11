import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/task.dart';
import '../controllers/task_provider.dart';
import '../widgets/task_pie_chart.dart';
import 'task_form_screen.dart';

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
  bool _isDescriptionExpanded = false;
  final TextEditingController _addSubtaskController = TextEditingController();

  @override
  void dispose() {
    _addSubtaskController.dispose();
    super.dispose();
  }

  void _openEditScreen(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          provider: widget.provider,
          taskToEdit: task,
        ),
      ),
    );
  }

  void _handleAddSubtask(String taskId) {
    final text = _addSubtaskController.text.trim();
    if (text.isNotEmpty) {
      widget.provider.addSubTask(taskId, text);
      _addSubtaskController.clear();
    }
  }

  void _showAddSubtaskDialog(String taskId, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Sub Task',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: isDark ? Colors.white : const Color(0xFF1E232E),
          ),
        ),
        content: TextField(
          controller: _addSubtaskController,
          autofocus: true,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E232E),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Subtask title',
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              _handleAddSubtask(taskId);
              Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditSubtaskDialog(String taskId, String subtaskId, String currentTitle, bool isDark) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Update Checklist Item',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: isDark ? Colors.white : const Color(0xFF1E232E),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white : const Color(0xFF1E232E),
          ),
          decoration: InputDecoration(
            hintText: 'Checklist item title',
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          onSubmitted: (val) {
            final newTitle = val.trim();
            if (newTitle.isNotEmpty) {
              widget.provider.updateSubTask(taskId, subtaskId, newTitle);
            }
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                widget.provider.updateSubTask(taskId, subtaskId, newTitle);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF1E232E);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final backBtnBg = isDark ? AppColors.darkCard : const Color(0xFFF1F5F9);
    final backBtnIcon = isDark ? Colors.white : const Color(0xFF1E232E);
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final tasks = widget.provider.tasks;
        final taskIndex = tasks.indexWhere((t) => t.id == widget.taskId);

        if (taskIndex == -1) {
          return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: Center(
              child: Text(
                'Task not found',
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          );
        }

        final task = tasks[taskIndex];
        final dateFormatted = task.dueDate != null
            ? DateFormat('dd-MM-yyyy').format(task.dueDate!)
            : '18-02-2026';
        final timeFormatted = task.dueDate != null
            ? DateFormat('h:mm a').format(task.dueDate!)
            : '9:00 AM-12:00 PM';

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: backBtnBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : Colors.transparent,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: backBtnIcon,
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              'Task Details',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark ? Colors.white70 : const Color(0xFF1E232E),
                ),
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : Colors.transparent,
                  ),
                ),
                onSelected: (val) {
                  if (val == 'edit') {
                    _openEditScreen(task);
                  } else if (val == 'toggle') {
                    widget.provider.toggleTaskCompletion(task.id);
                  } else if (val == 'delete') {
                    widget.provider.deleteTask(task.id);
                    Navigator.of(context).pop();
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text('Edit Task'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          task.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                          size: 18,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 10),
                        Text(task.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                        SizedBox(width: 10),
                        Text('Delete Task', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Date & Time Pills
                  Row(
                    children: [
                      _buildPill(dateFormatted, isDark),
                      const SizedBox(width: 10),
                      _buildPill(timeFormatted, isDark),
                      const Spacer(),
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: task.category.color.withValues(alpha: isDark ? 0.20 : 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: task.category.color.withValues(alpha: isDark ? 0.35 : 0.20),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(task.category.icon, size: 14, color: task.category.color),
                            const SizedBox(width: 6),
                            Text(
                              task.category.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: task.category.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Task Title
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      height: 1.25,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pie Chart with Legend
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: const TaskPieChart(),
                  ),

                  const SizedBox(height: 28),

                  // Section: Description
                  if (task.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDescriptionExpanded = !_isDescriptionExpanded;
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: _isDescriptionExpanded
                                  ? task.description
                                  : (task.description.length > 95
                                      ? '${task.description.substring(0, 95)}... '
                                      : task.description),
                            ),
                            if (task.description.length > 95 && !_isDescriptionExpanded)
                              TextSpan(
                                text: 'See more',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.primary : const Color(0xFF1E232E),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Section: Sub Task (Checklist)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Sub Task',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (task.subtasks.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${task.completedSubtasksCount}/${task.totalSubtasksCount}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                        tooltip: 'Add subtask',
                        onPressed: () => _showAddSubtaskDialog(task.id, isDark),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Subtasks list with checklist update capability
                  if (task.subtasks.isEmpty) ...[
                    GestureDetector(
                      onTap: () => _showAddSubtaskDialog(task.id, isDark),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Tap to add your first subtask item',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    ...task.subtasks.map((subtask) {
                      return _buildSubtaskItem(
                        task: task,
                        subtaskId: subtask.id,
                        title: subtask.title,
                        isCompleted: subtask.isCompleted,
                        dateText: dateFormatted,
                        isDark: isDark,
                      );
                    }),
                    const SizedBox(height: 8),
                    // Quick add checklist item container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_task_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _addSubtaskController,
                              onSubmitted: (_) => _handleAddSubtask(task.id),
                              style: TextStyle(
                                fontSize: 13,
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Add new checklist item...',
                                hintStyle: TextStyle(
                                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8),
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 24),
                            tooltip: 'Add item',
                            onPressed: () => _handleAddSubtask(task.id),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPill(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.transparent,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildSubtaskItem({
    required Task task,
    required String subtaskId,
    required String title,
    required bool isCompleted,
    required String dateText,
    required bool isDark,
  }) {
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final itemBorder = isDark
        ? (isCompleted ? AppColors.primary.withValues(alpha: 0.35) : AppColors.darkBorder)
        : (isCompleted ? AppColors.primary.withValues(alpha: 0.3) : const Color(0xFFF1F5F9));
    final titleColor = isCompleted
        ? (isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8))
        : (isDark ? AppColors.darkTextPrimary : const Color(0xFF1E232E));
    final checkboxBorder = isCompleted
        ? AppColors.primary
        : (isDark ? Colors.white24 : const Color(0xFFCBD5E1));
    final checkboxBg = isCompleted
        ? (isDark ? AppColors.primary.withValues(alpha: 0.25) : const Color(0xFFE0F7FA))
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: itemBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Clickable Checkbox that toggles status
            GestureDetector(
              key: ValueKey('checkbox_$subtaskId'),
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.provider.toggleSubTask(task.id, subtaskId);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: checkboxBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: checkboxBorder,
                    width: 1.5,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppColors.primary,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 14),

            // Title & Date: Tapping allows editing the checklist item title
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showEditSubtaskDialog(task.id, subtaskId, title, isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit_outlined,
                          size: 15,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Dedicated Edit Button
            IconButton(
              icon: const Icon(
                Icons.edit_note_rounded,
                size: 22,
                color: AppColors.primary,
              ),
              tooltip: 'Edit Item',
              visualDensity: VisualDensity.compact,
              onPressed: () => _showEditSubtaskDialog(task.id, subtaskId, title, isDark),
            ),

            // Right 3 dots menu with Mark Complete & Delete subtask options
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8),
              ),
              color: isDark ? AppColors.darkCard : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : Colors.transparent,
                ),
              ),
              onSelected: (val) {
                if (val == 'edit') {
                  _showEditSubtaskDialog(task.id, subtaskId, title, isDark);
                } else if (val == 'toggle') {
                  widget.provider.toggleSubTask(task.id, subtaskId);
                } else if (val == 'delete') {
                  widget.provider.removeSubTask(task.id, subtaskId);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Edit Item'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 8),
                      Text(isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
