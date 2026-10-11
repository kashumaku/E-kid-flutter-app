import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/core/database/app_database.dart';
import 'package:my_flutter_app/features/tasks/data/task_repository.dart';
import 'package:my_flutter_app/features/tasks/domain/models/task_category.dart';
import 'package:my_flutter_app/features/tasks/domain/models/task_priority.dart';
import 'package:my_flutter_app/features/tasks/presentation/controllers/task_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase dbHelper;
  late ITaskRepository repository;
  late TaskProvider provider;

  setUp(() async {
    dbHelper = AppDatabase.inMemory();
    repository = SqliteTaskRepository(dbHelper);
    provider = TaskProvider(repository);
    await provider.loadTasks();
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('SQLite TaskProvider Tests', () {
    test('Initializes with an empty list - NO SAMPLE TASKS', () {
      expect(provider.tasks.isEmpty, true);
      expect(provider.totalTasksCount, equals(0));
    });

    test('Adds a new task into SQLite database and re-reads it', () async {
      await provider.addTask(
        title: 'User experience design',
        description: 'Testing SQLite storage persistence',
        category: TaskCategory.design,
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(const Duration(hours: 4)),
        subtaskTitles: ['Website Redesign', 'Website Design'],
      );

      expect(provider.totalTasksCount, equals(1));
      final task = provider.tasks.first;
      expect(task.title, equals('User experience design'));
      expect(task.subtasks.length, equals(2));

      // Verify direct database query matches
      final dbTasks = await repository.getTasks();
      expect(dbTasks.length, equals(1));
      expect(dbTasks.first.title, equals('User experience design'));
      expect(dbTasks.first.subtasks.length, equals(2));
    });

    test('Toggles task completion in SQLite', () async {
      await provider.addTask(
        title: 'Meeting with designer',
        category: TaskCategory.work,
        priority: TaskPriority.urgent,
        subtaskTitles: ['Prepare slides'],
      );

      final task = provider.tasks.first;
      expect(task.isCompleted, false);

      await provider.toggleTaskCompletion(task.id);
      expect(provider.tasks.first.isCompleted, true);

      final dbTasks = await repository.getTasks();
      expect(dbTasks.first.isCompleted, true);
      expect(dbTasks.first.subtasks.first.isCompleted, true);
    });

    test('Deletes task and cascades to subtasks in SQLite', () async {
      await provider.addTask(
        title: 'Temporary Task',
        category: TaskCategory.personal,
        subtaskTitles: ['Step 1'],
      );

      expect(provider.totalTasksCount, equals(1));
      final taskId = provider.tasks.first.id;

      await provider.deleteTask(taskId);
      expect(provider.totalTasksCount, equals(0));

      final dbTasks = await repository.getTasks();
      expect(dbTasks.isEmpty, true);
    });

    test('Clears all tasks in SQLite', () async {
      await provider.addTask(title: 'Task 1', category: TaskCategory.work);
      await provider.addTask(title: 'Task 2', category: TaskCategory.study);

      expect(provider.totalTasksCount, equals(2));

      await provider.clearAllTasks();
      expect(provider.totalTasksCount, equals(0));

      final dbTasks = await repository.getTasks();
      expect(dbTasks.isEmpty, true);
    });

    test('Toggles subtask completion and syncs with SQLite', () async {
      await provider.addTask(
        title: 'Project checklist',
        category: TaskCategory.work,
        subtaskTitles: ['Item 1', 'Item 2'],
      );

      final task = provider.tasks.first;
      final subtaskId = task.subtasks.first.id;
      expect(task.subtasks.first.isCompleted, false);

      await provider.toggleSubTask(task.id, subtaskId);

      final updatedTask = provider.tasks.first;
      expect(updatedTask.subtasks.first.isCompleted, true);

      // Verify persisted in SQLite
      final dbTasks = await repository.getTasks();
      expect(dbTasks.first.subtasks.first.isCompleted, true);
    });

    test('Updates subtask title (checklist edit) and syncs with SQLite', () async {
      await provider.addTask(
        title: 'Design Wireframes',
        category: TaskCategory.design,
        subtaskTitles: ['Mobile View'],
      );

      final task = provider.tasks.first;
      final subtaskId = task.subtasks.first.id;

      await provider.updateSubTask(task.id, subtaskId, 'Mobile & Tablet View');

      expect(provider.tasks.first.subtasks.first.title, equals('Mobile & Tablet View'));

      // Verify persisted in SQLite
      final dbTasks = await repository.getTasks();
      expect(dbTasks.first.subtasks.first.title, equals('Mobile & Tablet View'));
    });

    test('Adds and removes subtask checklist items in SQLite', () async {
      await provider.addTask(
        title: 'Shopping',
        category: TaskCategory.personal,
        subtaskTitles: ['Milk'],
      );

      final task = provider.tasks.first;
      expect(task.subtasks.length, equals(1));

      await provider.addSubTask(task.id, 'Bread');
      expect(provider.tasks.first.subtasks.length, equals(2));
      expect(provider.tasks.first.subtasks.last.title, equals('Bread'));

      final breadId = provider.tasks.first.subtasks.last.id;
      await provider.removeSubTask(task.id, breadId);
      expect(provider.tasks.first.subtasks.length, equals(1));
      expect(provider.tasks.first.subtasks.first.title, equals('Milk'));
    });
  });
}
