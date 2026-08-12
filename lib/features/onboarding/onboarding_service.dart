import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _kOnboardingCompletedKey = 'onboarding_completed';

  /// Save onboarding completion status to persistent storage.
  Future<bool> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_kOnboardingCompletedKey, true);
  }

  /// Check if onboarding has already been completed.
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingCompletedKey) ?? false;
  }
}
