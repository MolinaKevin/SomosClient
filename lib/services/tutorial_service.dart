import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const _kOnboardingDone = 'onboarding_done';
  static const _kSpotlightDone  = 'spotlight_done';

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingDone) ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDone, true);
  }

  Future<bool> isSpotlightDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSpotlightDone) ?? false;
  }

  Future<void> setSpotlightDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSpotlightDone, true);
  }
}
