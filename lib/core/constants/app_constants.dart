class AppConstants {
  AppConstants._();

  static const String appName = "E'kid";
  static const String appTagline = 'Elevate Your Productivity';
  static const String appIconAsset = 'assets/icons/app_icon.png';
  static const String appIconTransparentAsset = 'assets/icons/app_icon_transparent.png';

  // Storage Keys
  static const String keyHasSeenOnboarding = 'apex_task_has_seen_onboarding';
  static const String keyTasksJson = 'apex_task_stored_tasks';
  static const String keyThemeMode = 'apex_task_theme_mode';

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animStandard = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
}
