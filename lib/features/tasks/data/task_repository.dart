import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../domain/models/task.dart';
import '../domain/models/subtask.dart';
import '../domain/models/task_category.dart';
import '../domain/models/task_priority.dart';

/// Abstract contract for task persistence operations.
abstract class ITaskRepository {
  Future<List<Task>> getTasks();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<void> clearAllTasks();
}

/// SQLite-backed implementation of [ITaskRepository].
class SqliteTaskRepository implements ITaskRepository {
  final AppDatabase _dbHelper;

  SqliteTaskRepository([AppDatabase? dbHelper])
      : _dbHelper = dbHelper ?? AppDatabase.instance;

  @override
  Future<List<Task>> getTasks() async {
    final db = await _dbHelper.database;

    // Query all tasks ordered by created_at DESC
    final List<Map<String, dynamic>> taskMaps = await db.query(
      'tasks',
      orderBy: 'created_at DESC',
    );

    if (taskMaps.isEmpty) {
      return []; // Pure empty list, no sample tasks
    }

    // Query all subtasks
    final List<Map<String, dynamic>> subtaskMaps = await db.query('subtasks');

    // Group subtasks by task_id
    final Map<String, List<SubTask>> subtasksByTaskId = {};
    for (final sMap in subtaskMaps) {
      final taskId = sMap['task_id'] as String;
      final subtask = SubTask(
        id: sMap['id'] as String,
        title: sMap['title'] as String,
        isCompleted: (sMap['is_completed'] as int) == 1,
      );
      subtasksByTaskId.putIfAbsent(taskId, () => []).add(subtask);
    }

    return taskMaps.map((map) {
      final taskId = map['id'] as String;
      List<String> tags = [];
      if (map['tags'] != null && (map['tags'] as String).isNotEmpty) {
        try {
          final decoded = jsonDecode(map['tags'] as String);
          if (decoded is List) {
            tags = decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {
          tags = (map['tags'] as String).split(',').where((t) => t.isNotEmpty).toList();
        }
      }

      return Task(
        id: taskId,
        title: map['title'] as String,
        description: (map['description'] as String?) ?? '',
        category: TaskCategory.findById((map['category_id'] as String?) ?? 'work'),
        priority: TaskPriority.fromString(map['priority'] as String?),
        dueDate: map['due_date'] != null ? DateTime.tryParse(map['due_date'] as String) : null,
        isCompleted: (map['is_completed'] as int) == 1,
        completedAt: map['completed_at'] != null ? DateTime.tryParse(map['completed_at'] as String) : null,
        tags: tags,
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
        subtasks: subtasksByTaskId[taskId] ?? const [],
      );
    }).toList();
  }

  @override
  Future<void> addTask(Task task) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      await txn.insert(
        'tasks',
        {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'category_id': task.category.id,
          'priority': task.priority.name,
          'due_date': task.dueDate?.toIso8601String(),
          'is_completed': task.isCompleted ? 1 : 0,
          'completed_at': task.completedAt?.toIso8601String(),
          'tags': jsonEncode(task.tags),
          'created_at': task.createdAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final subtask in task.subtasks) {
        await txn.insert(
          'subtasks',
          {
            'id': subtask.id,
            'task_id': task.id,
            'title': subtask.title,
            'is_completed': subtask.isCompleted ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> updateTask(Task task) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      await txn.update(
        'tasks',
        {
          'title': task.title,
          'description': task.description,
          'category_id': task.category.id,
          'priority': task.priority.name,
          'due_date': task.dueDate?.toIso8601String(),
          'is_completed': task.isCompleted ? 1 : 0,
          'completed_at': task.completedAt?.toIso8601String(),
          'tags': jsonEncode(task.tags),
          'created_at': task.createdAt.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [task.id],
      );

      // Re-sync subtasks
      await txn.delete(
        'subtasks',
        where: 'task_id = ?',
        whereArgs: [task.id],
      );

      for (final subtask in task.subtasks) {
        await txn.insert(
          'subtasks',
          {
            'id': subtask.id,
            'task_id': task.id,
            'title': subtask.title,
            'is_completed': subtask.isCompleted ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'subtasks',
        where: 'task_id = ?',
        whereArgs: [taskId],
      );
      await txn.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [taskId],
      );
    });
  }

  @override
  Future<void> clearAllTasks() async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('subtasks');
      await txn.delete('tasks');
    });
  }
}
