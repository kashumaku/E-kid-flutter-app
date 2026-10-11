import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/core/theme/theme_provider.dart';
import 'package:my_flutter_app/features/onboarding/data/onboarding_repository.dart';
import 'package:my_flutter_app/features/tasks/data/task_repository.dart';
import 'package:my_flutter_app/features/tasks/presentation/controllers/task_provider.dart';
import 'package:my_flutter_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ApexTask shows onboarding screen matching mockup on fresh launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final taskRepo = LocalStorageTaskRepository(prefs);
    final onboardingRepo = OnboardingRepository(prefs);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ITaskRepository>.value(value: taskRepo),
          Provider<IOnboardingRepository>.value(value: onboardingRepo),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider<TaskProvider>(create: (_) => TaskProvider(taskRepo)),
        ],
        child: const ApexTaskApp(hasCompletedOnboarding: false),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Onboarding Screen 1 elements matching mockup
    expect(find.text('Manage your task'), findsOneWidget);
    expect(find.text('Increase your productivity by managing\nyour personal and team task'), findsOneWidget);
    expect(find.text("Let's Start"), findsOneWidget);
  });

  testWidgets('ApexTask loads dashboard matching Screen 2 mockup', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'apex_task_has_seen_onboarding': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final taskRepo = LocalStorageTaskRepository(prefs);
    final onboardingRepo = OnboardingRepository(prefs);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ITaskRepository>.value(value: taskRepo),
          Provider<IOnboardingRepository>.value(value: onboardingRepo),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider<TaskProvider>(create: (_) => TaskProvider(taskRepo)),
        ],
        child: const ApexTaskApp(hasCompletedOnboarding: true),
      ),
    );
    await tester.pumpAndSettle();

    // Verify home dashboard elements matching Screen 2 mockup
    expect(find.text('Linda C. Ng'), findsOneWidget);
    expect(find.text('Your daily task\nalmost done!'), findsOneWidget);
    expect(find.text('View Task'), findsOneWidget);
    expect(find.text("Today's Task"), findsOneWidget);
    expect(find.text('Upcoming Task'), findsOneWidget);
  });

  testWidgets('Navigating to task details renders Screen 3 mockup', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'apex_task_has_seen_onboarding': true});
    final prefs = await SharedPreferences.getInstance();
    final taskRepo = LocalStorageTaskRepository(prefs);
    final onboardingRepo = OnboardingRepository(prefs);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ITaskRepository>.value(value: taskRepo),
          Provider<IOnboardingRepository>.value(value: onboardingRepo),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider<TaskProvider>(create: (_) => TaskProvider(taskRepo)),
        ],
        child: const ApexTaskApp(hasCompletedOnboarding: true),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "View Task"
    await tester.tap(find.text('View Task'));
    await tester.pumpAndSettle();

    // Verify Task Details elements matching Screen 3 mockup
    expect(find.text('Task Details'), findsOneWidget);
    expect(find.text('Finish on time'), findsOneWidget);
    expect(find.text('Past the deadline'), findsOneWidget);
    expect(find.text('Still ongoing'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Sub Task'), findsOneWidget);
  });
}
