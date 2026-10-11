import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/core/database/app_database.dart';
import 'package:my_flutter_app/core/theme/app_colors.dart';
import 'package:my_flutter_app/core/theme/theme_provider.dart';
import 'package:my_flutter_app/features/auth/data/auth_repository.dart';
import 'package:my_flutter_app/features/auth/presentation/controllers/auth_provider.dart';
import 'package:my_flutter_app/features/onboarding/data/onboarding_repository.dart';
import 'package:my_flutter_app/features/tasks/data/task_repository.dart';
import 'package:my_flutter_app/features/tasks/domain/models/task_category.dart';
import 'package:my_flutter_app/features/tasks/domain/models/task_priority.dart';
import 'package:my_flutter_app/features/tasks/presentation/controllers/task_provider.dart';
import 'package:my_flutter_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ApexTask shows onboarding screen matching mockup on fresh launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dbHelper = AppDatabase.inMemory();
    final taskRepo = SqliteTaskRepository(dbHelper);
    final onboardingRepo = OnboardingRepository(prefs);
    final taskProvider = TaskProvider(taskRepo);
    final authRepo = AuthRepository(prefs);
    final authProvider = AuthProvider(authRepo);
    await tester.runAsync(() async {
      await taskProvider.loadTasks();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ITaskRepository>.value(value: taskRepo),
          Provider<IOnboardingRepository>.value(value: onboardingRepo),
          Provider<IAuthRepository>.value(value: authRepo),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: const ApexTaskApp(hasCompletedOnboarding: false),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Onboarding Screen layout matching user reference layout
    expect(find.text('Master Your Workflow'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    // Tap Login to verify transition to SignInScreen with Phone & Password
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await dbHelper.close();
    });
  });

  testWidgets('ApexTask loads dashboard matching Screen 2 mockup with 0 sample tasks on start', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'apex_task_has_seen_onboarding': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final dbHelper = AppDatabase.inMemory();
    final taskRepo = SqliteTaskRepository(dbHelper);
    final onboardingRepo = OnboardingRepository(prefs);
    final taskProvider = TaskProvider(taskRepo);
    await tester.runAsync(() async {
      await taskProvider.loadTasks();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ITaskRepository>.value(value: taskRepo),
          Provider<IOnboardingRepository>.value(value: onboardingRepo),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
        ],
        child: const ApexTaskApp(hasCompletedOnboarding: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify home dashboard elements with 0 initial sample tasks
    expect(find.text('Linda C. Ng'), findsOneWidget);
    expect(find.text('Your daily plan\nstarts here!'), findsOneWidget);
    expect(find.text('Create Task'), findsOneWidget);
    expect(find.text("Today's Task"), findsOneWidget);
    expect(find.text('No tasks for today yet'), findsOneWidget);
    expect(find.text('Upcoming Task'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await dbHelper.close();
    });
  });

  testWidgets('HomeScreen dynamically adapts to Dark Theme', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'apex_task_has_seen_onboarding': true,
      'apex_task_theme_mode': 'dark',
    });
    final prefs = await SharedPreferences.getInstance();
    final dbHelper = AppDatabase.inMemory();
    final taskRepo = SqliteTaskRepository(dbHelper);
    final onboardingRepo = OnboardingRepository(prefs);
    final taskProvider = TaskProvider(taskRepo);
    final themeProvider = ThemeProvider(prefs);

    await tester.runAsync(() async {
      await taskProvider.loadTasks();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ITaskRepository>.value(value: taskRepo),
          Provider<IOnboardingRepository>.value(value: onboardingRepo),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
        ],
        child: const ApexTaskApp(hasCompletedOnboarding: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Linda C. Ng'), findsOneWidget);
    expect(find.text("Today's Task"), findsOneWidget);

    // Verify dark scaffold background
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, equals(AppColors.darkBackground));

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await dbHelper.close();
    });
  });

  testWidgets('Navigating to task details renders Screen 3 mockup when a task exists in SQLite', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'apex_task_has_seen_onboarding': true});
    final prefs = await SharedPreferences.getInstance();
    final dbHelper = AppDatabase.inMemory();
    final taskRepo = SqliteTaskRepository(dbHelper);
    final onboardingRepo = OnboardingRepository(prefs);
    final taskProvider = TaskProvider(taskRepo);

    // Insert task into SQLite via tester.runAsync
    await tester.runAsync(() async {
      await taskProvider.addTask(
        title: 'User experience design',
        description: 'Task management is the process which is monitoring your fast project\'s tasks through their various stages from start... See more',
        category: TaskCategory.design,
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(const Duration(hours: 4)),
        subtaskTitles: ['Website Redesign', 'Website Design'],
      );
      await taskProvider.loadTasks();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ITaskRepository>.value(value: taskRepo),
          Provider<IOnboardingRepository>.value(value: onboardingRepo),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
        ],
        child: const ApexTaskApp(hasCompletedOnboarding: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap "View Task"
    await tester.tap(find.text('View Task'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Task Details elements matching Screen 3 mockup
    expect(find.text('Task Details'), findsOneWidget);
    expect(find.text('User experience design'), findsOneWidget);
    expect(find.text('Finish on time'), findsOneWidget);
    expect(find.text('Past the deadline'), findsOneWidget);
    expect(find.text('Still ongoing'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Sub Task'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await dbHelper.close();
    });
  });

  testWidgets('SignUpScreen allows registration with Full Name, Phone number, and Password and navigates to Dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dbHelper = AppDatabase.inMemory();
    final taskRepo = SqliteTaskRepository(dbHelper);
    final onboardingRepo = OnboardingRepository(prefs);
    final taskProvider = TaskProvider(taskRepo);
    final authRepo = AuthRepository(prefs);
    final authProvider = AuthProvider(authRepo);

    await tester.runAsync(() async {
      await taskProvider.loadTasks();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ITaskRepository>.value(value: taskRepo),
          Provider<IOnboardingRepository>.value(value: onboardingRepo),
          Provider<IAuthRepository>.value(value: authRepo),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: const ApexTaskApp(hasCompletedOnboarding: false),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap "Sign Up" button on Onboarding Screen
    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify SignUp Screen fields
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Enter registration details
    await tester.enterText(find.byType(TextFormField).at(0), 'Jordan Rivera');
    await tester.enterText(find.byType(TextFormField).at(1), '555 8899');
    await tester.enterText(find.byType(TextFormField).at(2), 'securePass123');
    await tester.pump();

    // Scroll into view and tap Sign Up submit button
    final signUpButtonFinder = find.widgetWithText(ElevatedButton, 'Sign Up');
    await tester.ensureVisible(signUpButtonFinder);
    await tester.pump();
    await tester.tap(signUpButtonFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Dashboard opened with user's registered name
    expect(find.text('Jordan Rivera'), findsOneWidget);
    expect(find.text("Today's Task"), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await dbHelper.close();
    });
  });

  testWidgets('Tapping center + button opens TaskFormScreen as a full screen route', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'apex_task_has_seen_onboarding': true});
    final prefs = await SharedPreferences.getInstance();
    final dbHelper = AppDatabase.inMemory();
    final taskRepo = SqliteTaskRepository(dbHelper);
    final onboardingRepo = OnboardingRepository(prefs);
    final taskProvider = TaskProvider(taskRepo);

    await tester.runAsync(() async {
      await taskProvider.loadTasks();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ITaskRepository>.value(value: taskRepo),
          Provider<IOnboardingRepository>.value(value: onboardingRepo),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
        ],
        child: const ApexTaskApp(hasCompletedOnboarding: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap center floating '+' button in bottom dock
    final addIconFinder = find.byIcon(Icons.add_rounded).first;
    await tester.tap(addIconFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify TaskFormScreen full screen route is shown
    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Task Title'), findsOneWidget);
    expect(find.text('Priority Level'), findsOneWidget);
    expect(find.text('Schedule & Due Date'), findsOneWidget);
    expect(find.text('Subtask Checklist'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Create Task'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await dbHelper.close();
    });
  });

  testWidgets('TaskDetailScreen allows updating checklist: toggle, edit title, and inline add', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'apex_task_has_seen_onboarding': true});
    final prefs = await SharedPreferences.getInstance();
    final dbHelper = AppDatabase.inMemory();
    final taskRepo = SqliteTaskRepository(dbHelper);
    final onboardingRepo = OnboardingRepository(prefs);
    final taskProvider = TaskProvider(taskRepo);

    await tester.runAsync(() async {
      await taskProvider.addTask(
        title: 'Mobile App Polish',
        category: TaskCategory.design,
        subtaskTitles: ['Initial Draft'],
      );
      await taskProvider.loadTasks();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ITaskRepository>.value(value: taskRepo),
          Provider<IOnboardingRepository>.value(value: onboardingRepo),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
        ],
        child: const ApexTaskApp(hasCompletedOnboarding: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap "View Task" in hero banner
    await tester.tap(find.text('View Task'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Task Details'), findsOneWidget);
    expect(find.text('Initial Draft'), findsOneWidget);

    // 1. Edit checklist item title
    final editButtonFinder = find.byTooltip('Edit Item').first;
    await tester.tap(editButtonFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Update Checklist Item'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Initial Draft'), 'Final Production Draft');
    await tester.tap(find.text('Save Changes'));
    await tester.runAsync(() async => await Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    // Verify updated title is rendered
    expect(find.text('Final Production Draft'), findsOneWidget);

    // 2. Add another checklist item via inline quick-add field
    final addFieldFinder = find.widgetWithText(TextField, 'Add new checklist item...');
    await tester.enterText(addFieldFinder, 'QA Testing');
    await tester.tap(find.byTooltip('Add item'));
    await tester.runAsync(() async => await Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    // Verify newly added item appears in checklist
    expect(find.text('QA Testing'), findsOneWidget);

    // 3. Toggle checklist item completion
    final firstSubtaskId = taskProvider.tasks.first.subtasks.first.id;
    final checkboxFinder = find.byKey(ValueKey('checkbox_$firstSubtaskId'));
    await tester.ensureVisible(checkboxFinder);
    await tester.pump();
    await tester.tap(checkboxFinder);
    await tester.runAsync(() async => await Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    // Verify check icon appears
    expect(find.byIcon(Icons.check_rounded), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await dbHelper.close();
    });
  });
}
