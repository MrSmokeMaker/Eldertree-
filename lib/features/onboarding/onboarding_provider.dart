import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Провайдер состояния онбординга.
///
/// `null` — флаг ещё не прочитан (показываем сплэш), `false`/`true` — прочитан.
/// Раньше состояние стартовало со `false`, из-за чего первый кадр всегда
/// монтировал OnboardingScreen, а без MaterialApp это приводило к падению.
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool?>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool?> {
  OnboardingNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      state = prefs.getBool('onboarding_completed') ?? false;
    } catch (_) {
      // Хранилище недоступно — считаем онбординг непройденным.
      state = false;
    }
  }

  Future<void> complete() async {
    // Переключаем UI сразу, запись в хранилище — best effort.
    state = true;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (_) {
      // ignore: запись флага не критична для текущей сессии
    }
  }
}
