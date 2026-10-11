import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/features/tasks/data/task_repository.dart';
import 'package:my_flutter_app/features/tasks/domain/models/task_category.dart';
import 'package:my_flutter_app/features/tasks/domain/models/task_priority.dart';
import 'package:my_flutter_app/features/tasks/presentation/controllers/task_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late ITaskRepository repository;
  late TaskProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = LocalStorageTaskRepository(prefs);
    provider = TaskProvider(repository);
    await provider.loadTasks();
  });

  group('TaskProvider Unit Tests', () {
    test('Initializes with default seed tasks', () {
      expect(provider.tasks.isNotEmpty, true);
      expect(provider.totalTasksCount, greaterThan(0));
    });

    test('Adds a new task with subtasks correctly', () async {
      final initialCount = provider.totalTasksCount;
      await provider.addTask(
        title: 'New Unit Test Task',
        description: 'Verifying senior architecture',
        category: TaskCategory.work,
        priority: TaskPriority.urgent,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        subtaskTitles: ['Step 1', 'Step 2'],
      );

      expect(provider.totalTasksCount, equals(initialCount + 1));
      final created = provider.tasks.first;
      expect(created.title, equals('New Unit Test Task'));
      expect(created.priority, equals(TaskPriority.urgent));
      expect(created.subtasks.length, equals(2));
      expect(created.isCompleted, equals(false));
    });

    test('Toggles task completion and marks subtasks', () async {
      final firstTask = provider.tasks.first;
      final originalStatus = firstTask.isCompleted;

      await provider.toggleTaskCompletion(firstTask.id);
      final updated = provider.tasks.firstWhere((t) => t.id == firstTask.id);

      expect(updated.isCompleted, equals(!originalStatus));
      if (updated.isCompleted) {
        expect(updated.subtasks.every((s) => s.isCompleted), true);
      }
    });

    test('Filters by category correctly', () {
      provider.setCategory(TaskCategory.design);
      expect(provider.selectedCategory, equals(TaskCategory.design));
      for (final task in provider.filteredTasks) {
        expect(task.category.id, equals(TaskCategory.design.id));
      }
    });

    test('Search query matches title and tags', () {
      provider.setSearchQuery('Design');
      for (final task in provider.filteredTasks) {
        final matches = task.title.toLowerCase().contains('design') ||
            task.description.toLowerCase().contains('design') ||
            task.tags.any((t) => t.toLowerCase().contains('design'));
        expect(matches, true);
      }
    });

    test('Deletes a task', () async {
      final taskToDelete = provider.tasks.first;
      final initialCount = provider.totalTasksCount;

      await provider.deleteTask(taskToDelete.id);
      expect(provider.totalTasksCount, equals(initialCount - 1));
      expect(provider.tasks.any((t) => t.id == taskToDelete.id), false);
    });

    test('Toggles subtask and updates parent progress', () async {
      final taskWithSubtasks = provider.tasks.firstWhere((t) => t.subtasks.isNotEmpty);
      final subtask = taskWithSubtasks.subtasks.first;
      final originalSubtaskStatus = subtask.isCompleted;

      await provider.toggleSubTask(taskWithSubtasks.id, subtask.id);
      final updated = provider.tasks.firstWhere((t) => t.id == taskWithSubtasks.id);
      final updatedSubtask = updated.subtasks.firstWhere((s) => s.id == subtask.id);

      expect(updatedSubtask.isCompleted, equals(!originalSubtaskStatus));
    });
  });
}
