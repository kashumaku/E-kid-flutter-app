import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/core/database/app_database.dart';
import 'package:my_flutter_app/core/theme/app_colors.dart';
import 'package:my_flutter_app/core/theme/app_theme.dart';
import 'package:my_flutter_app/core/theme/theme_provider.dart';
import 'package:my_flutter_app/features/tasks/data/task_repository.dart';
import 'package:my_flutter_app/features/tasks/domain/models/task_category.dart';
import 'package:my_flutter_app/features/tasks/domain/models/task_priority.dart';
import 'package:my_flutter_app/features/tasks/presentation/controllers/task_provider.dart';
import 'package:my_flutter_app/features/tasks/presentation/screens/task_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TaskDetailScreen Theme Awareness', () {
    testWidgets('TaskDetailScreen renders with dark background and styling in dark mode', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'apex_task_theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      final dbHelper = AppDatabase.inMemory();
      final taskRepo = SqliteTaskRepository(dbHelper);
      final taskProvider = TaskProvider(taskRepo);

      late String taskId;
      await tester.runAsync(() async {
        await taskProvider.addTask(
          title: 'Review System Specs',
          description: 'Dark mode theme audit and validation for the design system.',
          category: TaskCategory.design,
          priority: TaskPriority.urgent,
          subtaskTitles: ['Verify contrast', 'Check borders'],
        );
        await taskProvider.loadTasks();
        taskId = taskProvider.tasks.first.id;
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(prefs)),
            ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: TaskDetailScreen(taskId: taskId, provider: taskProvider),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Dark Scaffold Background
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);
      final scaffold = tester.widget<Scaffold>(scaffoldFinder);
      expect(scaffold.backgroundColor, equals(AppColors.darkBackground));

      // Verify title rendered
      expect(find.text('Task Details'), findsOneWidget);
      expect(find.text('Review System Specs'), findsOneWidget);
      expect(find.text('Sub Task'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async {
        await dbHelper.close();
      });
    });
  });
}
