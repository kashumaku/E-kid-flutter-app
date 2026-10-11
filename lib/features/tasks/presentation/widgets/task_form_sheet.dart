import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/models/task.dart';
import '../../domain/models/task_category.dart';
import '../../domain/models/task_priority.dart';
import '../controllers/task_provider.dart';

class TaskFormSheet extends StatefulWidget {
  final TaskProvider provider;
  final Task? taskToEdit;

  const TaskFormSheet({
    super.key,
    required this.provider,
    this.taskToEdit,
  });

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _tagController;
  late TextEditingController _subtaskInputController;

  late TaskCategory _selectedCategory;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedTime;
  List<String> _subtasks = [];
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    final edit = widget.taskToEdit;
    _titleController = TextEditingController(text: edit?.title ?? '');
    _descController = TextEditingController(text: edit?.description ?? '');
    _tagController = TextEditingController();
    _subtaskInputController = TextEditingController();

    _selectedCategory = edit?.category ?? TaskCategory.work;
    _selectedPriority = edit?.priority ?? TaskPriority.medium;
    _selectedDueDate = edit?.dueDate;
    if (_selectedDueDate != null) {
      _selectedTime = TimeOfDay.fromDateTime(_selectedDueDate!);
    }
    _subtasks = edit?.subtasks.map((s) => s.title).toList() ?? [];
    _tags = List<String>.from(edit?.tags ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagController.dispose();
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
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      setState(() {
        if (_selectedTime != null) {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
        } else {
          _selectedDueDate = pickedDate;
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        final baseDate = _selectedDueDate ?? DateTime.now();
        _selectedDueDate = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
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
        _subtasks.add(text);
        _subtaskInputController.clear();
      });
    }
  }

  void _addTag() {
    final text = _tagController.text.trim().replaceAll('#', '');
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _tagController.clear();
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.taskToEdit != null) {
      // Edit mode
      final updated = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        clearDueDate: _selectedDueDate == null,
        tags: _tags,
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
        tags: _tags,
        subtaskTitles: _subtasks,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Task' : 'New Task',
                    style: AppTypography.displaySmall.copyWith(fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                autofocus: !isEditing,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  labelText: 'Task Title *',
                  hintText: 'What needs to be done?',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Description Field
              TextFormField(
                controller: _descController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Description / Notes',
                  hintText: 'Add additional context or requirements...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 20),

              // Category Selector
              const Text(
                'Category',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TaskCategory.defaultCategories.map((cat) {
                    final isSelected = _selectedCategory.id == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? cat.color : cat.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : cat.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat.icon,
                                size: 16,
                                color: isSelected ? Colors.white : cat.color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : cat.color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Priority Selector
              const Text(
                'Priority Level',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPriority = priority),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? priority.color
                                : priority.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : priority.color.withValues(alpha: 0.3),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                priority.icon,
                                size: 14,
                                color: isSelected ? Colors.white : priority.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                priority.displayName,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : priority.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Due Date & Time Picker
              const Text(
                'Schedule & Deadline',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: Text(
                        _selectedDueDate != null
                            ? DateFormatter.formatShortDate(_selectedDueDate!)
                            : 'Pick Date',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time_rounded, size: 16),
                      label: Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Pick Time',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  if (_selectedDueDate != null) ...[
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      tooltip: 'Clear deadline',
                      onPressed: () {
                        setState(() {
                          _selectedDueDate = null;
                          _selectedTime = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // Subtasks Checklist Builder (Only for new task or can add to list)
              if (!isEditing) ...[
                const Text(
                  'Checklist Subtasks',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subtaskInputController,
                        onSubmitted: (_) => _addSubtask(),
                        decoration: const InputDecoration(
                          hintText: 'Add a subtask step...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addSubtask,
                      icon: const Icon(Icons.add, size: 18),
                      style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                  ],
                ),
                if (_subtasks.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...List.generate(_subtasks.length, (idx) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.subdirectory_arrow_right_rounded, size: 16, color: AppColors.primaryLight),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _subtasks[idx],
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded, size: 16, color: AppColors.error),
                            onPressed: () {
                              setState(() => _subtasks.removeAt(idx));
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 20),
              ],

              // Tags
              const Text(
                'Tags',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      onSubmitted: (_) => _addTag(),
                      decoration: const InputDecoration(
                        hintText: 'Add a tag (e.g. UX, Release)...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addTag,
                    icon: const Icon(Icons.add, size: 18),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text('#$tag', style: const TextStyle(fontSize: 11)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        setState(() => _tags.remove(tag));
                      },
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Task',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
