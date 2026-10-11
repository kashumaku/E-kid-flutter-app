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

  testWidgets('ApexTask shows onboarding screen on fresh launch', (WidgetTester tester) async {
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

    // Verify Onboarding elements appear
    expect(find.text('ApexTask'), findsOneWidget);
    expect(find.text('SEAMLESS FLOW'), findsOneWidget);
    expect(find.text('Conquer Your Day With Precision'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('ApexTask loads dashboard when onboarding already completed', (WidgetTester tester) async {
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

    // Verify home dashboard elements
    expect(find.text("Today's Focus"), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
