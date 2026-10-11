import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/core/database/app_database.dart';
import 'package:my_flutter_app/core/theme/theme_provider.dart';
import 'package:my_flutter_app/features/auth/data/auth_repository.dart';
import 'package:my_flutter_app/features/auth/presentation/controllers/auth_provider.dart';
import 'package:my_flutter_app/features/onboarding/data/onboarding_repository.dart';
import 'package:my_flutter_app/features/tasks/data/task_repository.dart';
import 'package:my_flutter_app/features/tasks/domain/models/task_category.dart';
import 'package:my_flutter_app/features/tasks/domain/models/task_priority.dart';
import 'package:my_flutter_app/features/tasks/presentation/controllers/task_provider.dart';
import 'package:my_flutter_app/features/tasks/presentation/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SettingsScreen has abstract UI, expanded menus, and NO System Architecture menu', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'apex_task_has_seen_onboarding': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final dbHelper = AppDatabase.inMemory();
    final taskRepo = SqliteTaskRepository(dbHelper);
    final onboardingRepo = OnboardingRepository(prefs);
    final taskProvider = TaskProvider(taskRepo);
    final authRepo = AuthRepository(prefs);
    final authProvider = AuthProvider(authRepo);
    final themeProvider = ThemeProvider(prefs);

    // Seed a task to test metric calculation in abstract profile hero
    await tester.runAsync(() async {
      await taskProvider.addTask(
        title: 'Complete architecture review',
        category: TaskCategory.work,
        priority: TaskPriority.high,
        subtaskTitles: ['Part 1', 'Part 2'],
      );
      await taskProvider.loadTasks();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ITaskRepository>.value(value: taskRepo),
          Provider<IOnboardingRepository>.value(value: onboardingRepo),
          Provider<IAuthRepository>.value(value: authRepo),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: MaterialApp(
          home: SettingsScreen(onboardingRepository: onboardingRepo),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify System Architecture is COMPLETELY REMOVED
    expect(find.text('System Architecture'), findsNothing);
    expect(find.text('Architecture Highlights'), findsNothing);

    // 2. Verify Abstract Profile Hero & Metrics
    expect(find.text('Settings & Profile'), findsOneWidget);
    expect(find.text('Linda C. Ng'), findsOneWidget);
    expect(find.text("E'KID PRO"), findsOneWidget);
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('DONE'), findsOneWidget);
    expect(find.text('FOCUS'), findsOneWidget);

    // 3. Verify Added Menus (Workspace & Display)
    expect(find.text('WORKSPACE & DISPLAY'), findsOneWidget);
    expect(find.text('Theme Interface'), findsOneWidget);
    expect(find.text('Default Task Priority'), findsOneWidget);
    expect(find.text('Compact Feed Density'), findsOneWidget);

    // 4. Verify Added Menus (Signals & Alerts)
    expect(find.text('SIGNALS & ALERTS'), findsOneWidget);
    expect(find.text('Due Date Reminders'), findsOneWidget);
    expect(find.text('Morning Focus Digest'), findsOneWidget);
    expect(find.text('Tactile Haptic Feedback'), findsOneWidget);

    // 5. Scroll to Data Vault & Storage
    await tester.scrollUntilVisible(find.text('DATA VAULT & STORAGE'), 200);
    expect(find.text('DATA VAULT & STORAGE'), findsOneWidget);
    expect(find.text('Export & Backup Vault'), findsOneWidget);
    expect(find.text('Replay Onboarding Tour'), findsOneWidget);
    expect(find.text('Zero-Telemetry Pledge'), findsOneWidget);
    expect(find.text('Clear All Tasks'), findsOneWidget);

    // 6. Test Interactive Modal: Export & Backup Vault
    await tester.ensureVisible(find.text('Export & Backup Vault'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export & Backup Vault'));
    await tester.pumpAndSettle();

    expect(find.text('Data Vault Export'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    // Dismiss modal
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // 7. Test Interactive Modal: Zero-Telemetry Pledge
    await tester.ensureVisible(find.text('Zero-Telemetry Pledge'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zero-Telemetry Pledge'));
    await tester.pumpAndSettle();

    expect(find.text('Zero-Telemetry Pledge'), findsWidgets);
    expect(find.text('Understood'), findsOneWidget);
    await tester.tap(find.text('Understood'));
    await tester.pumpAndSettle();

    // 8. Scroll to Community & Session at bottom
    await tester.scrollUntilVisible(find.text('COMMUNITY & ABOUT'), 200);
    expect(find.text('COMMUNITY & ABOUT'), findsOneWidget);
    expect(find.text("About E'kid"), findsOneWidget);
    expect(find.text('Workflow & Gestures'), findsOneWidget);
    expect(find.text("Recommend E'kid"), findsOneWidget);

    await tester.scrollUntilVisible(find.text('SESSION'), 200);
    expect(find.text('SESSION'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await dbHelper.close();
    });
  });
}
