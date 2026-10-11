import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/task.dart';
import '../controllers/task_provider.dart';
import '../widgets/task_pie_chart.dart';
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
  bool _isDescriptionExpanded = false;
  final TextEditingController _addSubtaskController = TextEditingController();

  @override
  void dispose() {
    _addSubtaskController.dispose();
    super.dispose();
  }

  void _openEditSheet(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => TaskFormSheet(
        provider: widget.provider,
        taskToEdit: task,
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

  @override
  Widget build(BuildContext context) {
    final tasks = widget.provider.tasks;
    final taskIndex = tasks.indexWhere((t) => t.id == widget.taskId);

    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Task not found')),
      );
    }

    final task = tasks[taskIndex];
    final dateFormatted = task.dueDate != null
        ? DateFormat('dd-MM-yyyy').format(task.dueDate!)
        : '18-02-2026';
    const timeFormatted = '9:00 AM-12:00 PM';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Color(0xFF1E232E),
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Task Details',
          style: TextStyle(
            color: Color(0xFF1E232E),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
            onPressed: () => _openEditSheet(task),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Task Title: "User experience design"
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E232E),
                ),
              ),

              const SizedBox(height: 12),

              // Date & Time Pills
              Row(
                children: [
                  _buildPill(dateFormatted),
                  const SizedBox(width: 10),
                  _buildPill(timeFormatted),
                ],
              ),

              const SizedBox(height: 24),

              // Pie Chart with Legend
              const TaskPieChart(),

              const SizedBox(height: 28),

              // Section: Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E232E),
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
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF64748B),
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
                        const TextSpan(
                          text: 'See more',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E232E),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Section: Sub Task
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sub Task',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E232E),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                    tooltip: 'Add subtask',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Add Sub Task'),
                          content: TextField(
                            controller: _addSubtaskController,
                            autofocus: true,
                            decoration: const InputDecoration(hintText: 'Subtask title'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _handleAddSubtask(task.id);
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Subtasks list matching mockup
              if (task.subtasks.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No subtasks created yet.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
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
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox matching mockup
          GestureDetector(
            onTap: () => widget.provider.toggleSubTask(task.id, subtaskId),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFFE0F7FA) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCompleted ? AppColors.primary : const Color(0xFFCBD5E1),
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

          // Title & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E232E),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Right 3 dots icon
          IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
            onPressed: () {
              widget.provider.removeSubTask(task.id, subtaskId);
            },
          ),
        ],
      ),
    );
  }
}
