import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/subtask.dart';
import '../../domain/models/task.dart';
import '../../domain/models/task_category.dart';
import '../../domain/models/task_priority.dart';
import '../controllers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskProvider provider;
  final Task? taskToEdit;
  final DateTime? initialDueDate;

  const TaskFormScreen({
    super.key,
    required this.provider,
    this.taskToEdit,
    this.initialDueDate,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _subtaskInputController;

  late TaskCategory _selectedCategory;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedTime;
  List<SubTask> _subtasks = [];

  @override
  void initState() {
    super.initState();
    final edit = widget.taskToEdit;
    _titleController = TextEditingController(text: edit?.title ?? '');
    _descController = TextEditingController(text: edit?.description ?? '');
    _subtaskInputController = TextEditingController();

    _selectedCategory = edit?.category ?? TaskCategory.design;
    _selectedPriority = edit?.priority ?? TaskPriority.high;
    _selectedDueDate = edit?.dueDate ?? widget.initialDueDate;
    if (_selectedDueDate != null) {
      _selectedTime = TimeOfDay.fromDateTime(_selectedDueDate!);
    }
    _subtasks = edit?.subtasks.map((s) => s.copyWith()).toList() ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskInputController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.lightTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        final time = _selectedTime ?? const TimeOfDay(hour: 9, minute: 0);
        _selectedDueDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          time.hour,
          time.minute,
        );
        _selectedTime = time;
      });
    }
  }

  Future<void> _pickTime() async {
    final initialTime = _selectedTime ?? TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.lightTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        final base = _selectedDueDate ?? DateTime.now();
        _selectedDueDate = DateTime(
          base.year,
          base.month,
          base.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _addSubtask() {
    final text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(SubTask(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: text,
          isCompleted: false,
        ));
        _subtaskInputController.clear();
      });
    }
  }

  void _showEditSubtaskInForm(int index) {
    final current = _subtasks[index];
    final controller = TextEditingController(text: current.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Sub Task'),
        content: TextField(
          controller: controller,
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
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                setState(() {
                  _subtasks[index] = current.copyWith(title: newTitle);
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.taskToEdit != null) {
      // Edit mode: correctly preserve & sync subtasks
      final allCompleted = _subtasks.isNotEmpty && _subtasks.every((s) => s.isCompleted);
      final updated = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        clearDueDate: _selectedDueDate == null,
        subtasks: _subtasks,
        isCompleted: _subtasks.isNotEmpty ? allCompleted : widget.taskToEdit!.isCompleted,
        completedAt: allCompleted ? (widget.taskToEdit!.completedAt ?? DateTime.now()) : null,
        clearCompletedAt: !allCompleted,
      );
      widget.provider.updateTask(updated);
    } else {
      // Create mode
      widget.provider.addTask(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        subtaskTitles: _subtasks.map((s) => s.title).toList(),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
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
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: isDark ? Colors.white : const Color(0xFF1E232E),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          isEditing ? 'Edit Task' : 'New Task',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1E232E),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: TextButton(
                onPressed: _saveTask,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  isEditing ? 'Save' : 'Create',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card 1: Title & Description
                      _buildCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Task Title',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _titleController,
                              autofocus: !isEditing,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1E232E),
                              ),
                              decoration: InputDecoration(
                                hintText: 'e.g. User experience design',
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter a task title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descController,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF1E232E),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Add description, context or goals...',
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Card 2: Category Selector
                      _buildCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: TaskCategory.defaultCategories.map((cat) {
                                  final isSelected = _selectedCategory.id == cat.id;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedCategory = cat),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? cat.color
                                            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: cat.color.withValues(alpha: 0.35),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            cat.icon,
                                            size: 16,
                                            color: isSelected
                                                ? Colors.white
                                                : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            cat.name,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Card 3: Priority Selector
                      _buildCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Priority Level',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: TaskPriority.values.map((priority) {
                                final isSelected = _selectedPriority == priority;
                                final color = _getPriorityColor(priority);
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedPriority = priority),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? color
                                            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: color.withValues(alpha: 0.35),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          priority.name.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.4,
                                            color: isSelected
                                                ? Colors.white
                                                : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 18),

                      // Card 4: Date & Time Schedule
                      _buildCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Schedule & Due Date',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Date Pill Card
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _pickDate,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _selectedDueDate != null
                                                  ? DateFormat('dd-MM-yyyy').format(_selectedDueDate!)
                                                  : 'Set Date',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? Colors.white : const Color(0xFF1E232E),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Time Pill Card
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _pickTime,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFFFF6B4A)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _selectedTime != null
                                                  ? _selectedTime!.format(context)
                                                  : '9:00 AM',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? Colors.white : const Color(0xFF1E232E),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Card 5: Subtask Checklist
                      _buildCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtask Checklist',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                if (_subtasks.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_subtasks.length} items',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Input to add subtask
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _subtaskInputController,
                                    onSubmitted: (_) => _addSubtask(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white : const Color(0xFF1E232E),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Add checklist item (e.g. Website Design)...',
                                      hintStyle: TextStyle(
                                        color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                                        fontSize: 13,
                                      ),
                                      filled: true,
                                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  onPressed: _addSubtask,
                                  icon: const Icon(Icons.add_rounded, size: 20),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            if (_subtasks.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              ..._subtasks.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Clickable Checkbox
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _subtasks[index] = item.copyWith(isCompleted: !item.isCompleted);
                                          });
                                        },
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: item.isCompleted ? const Color(0xFFE0F7FA) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: item.isCompleted ? AppColors.primary : const Color(0xFFCBD5E1),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: item.isCompleted
                                              ? const Center(
                                                  child: Icon(Icons.check_rounded, size: 14, color: AppColors.primary),
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _showEditSubtaskInForm(index),
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: item.isCompleted
                                                  ? const Color(0xFF94A3B8)
                                                  : (isDark ? Colors.white : const Color(0xFF1E232E)),
                                              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _showEditSubtaskInForm(index),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 6),
                                          child: Icon(Icons.edit_outlined, size: 16, color: Color(0xFF94A3B8)),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() => _subtasks.removeAt(index));
                                        },
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Persistent Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: AppColors.primary.withValues(alpha: 0.35),
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Create Task',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.urgent:
        return AppColors.priorityUrgent;
    }
  }
}
