class OnboardingService {
  /// Save onboarding completion status to persistent storage.
  Future<bool> setOnboardingCompleted() async {
    // Shared preferences or local storage saving can be plugged in here
    return true;
  }

  /// Check if onboarding has already been completed.
  Future<bool> isOnboardingCompleted() async {
    return false;
  }
}
