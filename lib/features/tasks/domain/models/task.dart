import 'subtask.dart';
import 'task_category.dart';
import 'task_priority.dart';
import '../../../../core/utils/date_formatter.dart';

/// Core domain entity representing a Task in the application.
class Task {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<SubTask> subtasks;
  final List<String> tags;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.subtasks = const [],
    this.tags = const [],
    required this.createdAt,
  });

  // Computed helper getters
  int get completedSubtasksCount =>
      subtasks.where((subtask) => subtask.isCompleted).length;

  int get totalSubtasksCount => subtasks.length;

  double get subtasksProgress =>
      totalSubtasksCount == 0 ? 0.0 : completedSubtasksCount / totalSubtasksCount;

  bool get isOverdue => !isCompleted && DateFormatter.isOverdue(dueDate);

  bool get isDueToday => DateFormatter.isDueToday(dueDate);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    List<SubTask>? subtasks,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      subtasks: subtasks ?? this.subtasks,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': category.id,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      category: TaskCategory.findById(map['categoryId'] as String? ?? 'work'),
      priority: TaskPriority.fromString(map['priority'] as String?),
      dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate'] as String) : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: map['completedAt'] != null ? DateTime.tryParse(map['completedAt'] as String) : null,
      subtasks: (map['subtasks'] as List<dynamic>?)
              ?.map((s) => SubTask.fromMap(s as Map<String, dynamic>))
              .toList() ??
          const [],
      tags: (map['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? const [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
