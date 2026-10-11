import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

abstract class IOnboardingRepository {
  bool hasCompletedOnboarding();
  Future<void> setOnboardingCompleted(bool completed);
}

class OnboardingRepository implements IOnboardingRepository {
  final SharedPreferences _prefs;

  OnboardingRepository(this._prefs);

  @override
  bool hasCompletedOnboarding() {
    return _prefs.getBool(AppConstants.keyHasSeenOnboarding) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(AppConstants.keyHasSeenOnboarding, completed);
  }
}
