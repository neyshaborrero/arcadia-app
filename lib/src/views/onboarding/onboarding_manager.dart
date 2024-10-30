// lib/onboarding/onboarding_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingManager {
  static const _onboardingKey = 'onboarding_seen';

  // Check if the onboarding screens have been seen
  Future<bool> hasSeenOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // Mark onboarding as completed
  Future<void> setOnboardingSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // Clear the onboarding seen preference (for testing purposes)
  Future<void> clearOnboardingSeenPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey); // Remove only the onboarding key
    print("Onboarding seen preference has been cleared.");
  }
}
