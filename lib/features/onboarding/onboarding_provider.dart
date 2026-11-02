import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider that stores whether the onboarding has been completed.
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('onboarding_completed') ?? false;
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    state = true;
  }
}
