import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../domain/models/task.dart';
import 'task_mock_data.dart';

/// Abstract contract for task persistence operations.
abstract class ITaskRepository {
  Future<List<Task>> getTasks();
  Future<void> saveTasks(List<Task> tasks);
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<void> resetToDefaultSeed();
}

/// SharedPreferences-backed implementation of [ITaskRepository].
class LocalStorageTaskRepository implements ITaskRepository {
  final SharedPreferences _prefs;

  LocalStorageTaskRepository(this._prefs);

  @override
  Future<List<Task>> getTasks() async {
    final rawJson = _prefs.getString(AppConstants.keyTasksJson);
    if (rawJson == null || rawJson.isEmpty) {
      // Initialize with realistic mock seed on first launch
      final seed = TaskMockData.getInitialTasks();
      await saveTasks(seed);
      return seed;
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded.map((e) => Task.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback if corrupted
      final seed = TaskMockData.getInitialTasks();
      await saveTasks(seed);
      return seed;
    }
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final mapped = tasks.map((t) => t.toMap()).toList();
    await _prefs.setString(AppConstants.keyTasksJson, jsonEncode(mapped));
  }

  @override
  Future<void> addTask(Task task) async {
    final tasks = await getTasks();
    tasks.insert(0, task);
    await saveTasks(tasks);
  }

  @override
  Future<void> updateTask(Task task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await saveTasks(tasks);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await saveTasks(tasks);
  }

  @override
  Future<void> resetToDefaultSeed() async {
    final seed = TaskMockData.getInitialTasks();
    await saveTasks(seed);
  }
}
