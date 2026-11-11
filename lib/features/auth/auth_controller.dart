import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_providers.dart';

part 'auth_controller.g.dart';

class SignUpResult {
  final bool isConfirmed;
  final String? email;

  const SignUpResult({
    required this.isConfirmed,
    this.email,
  });
}

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  String _mapAuthException(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      final code = error.statusCode;

      if (msg.contains('rate limit') || code == '429') {
        return 'Превышен лимит отправки писем подтверждения. '
            'В панели Supabase (Authentication -> Providers -> Email) '
            'отключите тумблер "Confirm email" или подождите около часа.';
      }
      if (msg.contains('already registered') ||
          msg.contains('user already exists')) {
        return 'Пользователь с таким email уже зарегистрирован. Переключитесь на вход.';
      }
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid credentials')) {
        return 'Неверный email или пароль.';
      }
      if (msg.contains('password should be at least') ||
          msg.contains('weak password')) {
        return 'Пароль слишком простой (минимум 6 символов).';
      }
      if (msg.contains('email not confirmed')) {
        return 'Email ещё не подтверждён. Проверьте почту или отключите "Confirm email" в Supabase.';
      }
      return error.message;
    }
    return error.toString();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref.read(supabaseProvider).auth.signInWithPassword(
            email: email,
            password: password,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      final friendlyMessage = _mapAuthException(e);
      state = AsyncError(friendlyMessage, st);
    }
  }

  Future<SignUpResult?> signUp(String email, String password) async {
    state = const AsyncLoading();
    try {
      final response = await ref.read(supabaseProvider).auth.signUp(
            email: email,
            password: password,
          );
      state = const AsyncData(null);

      final hasSession = response.session != null;
      return SignUpResult(
        isConfirmed: hasSession,
        email: email,
      );
    } catch (e, st) {
      final friendlyMessage = _mapAuthException(e);
      state = AsyncError(friendlyMessage, st);
      return null;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(supabaseProvider).auth.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      final friendlyMessage = _mapAuthException(e);
      state = AsyncError(friendlyMessage, st);
    }
  }
}
