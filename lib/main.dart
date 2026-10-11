import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/navigation/main_nav_scaffold.dart';
import 'features/onboarding/data/onboarding_repository.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/tasks/data/task_repository.dart';
import 'features/tasks/presentation/controllers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize persistent preferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize repositories (Clean Architecture Data layer)
  final ITaskRepository taskRepository = LocalStorageTaskRepository(prefs);
  final IOnboardingRepository onboardingRepository = OnboardingRepository(prefs);

  runApp(
    MultiProvider(
      providers: [
        Provider<ITaskRepository>.value(value: taskRepository),
        Provider<IOnboardingRepository>.value(value: onboardingRepository),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(taskRepository),
        ),
      ],
      child: ApexTaskApp(
        hasCompletedOnboarding: onboardingRepository.hasCompletedOnboarding(),
      ),
    ),
  );
}

class ApexTaskApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const ApexTaskApp({
    super.key,
    required this.hasCompletedOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final onboardingRepo = context.read<IOnboardingRepository>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: hasCompletedOnboarding
          ? const MainNavScaffold()
          : OnboardingScreen(onboardingRepository: onboardingRepo),
    );
  }
}
