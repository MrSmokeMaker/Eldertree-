import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/supabase_providers.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/tree_list/presentation/tree_list_screen.dart';
import '../../features/tree_canvas/presentation/tree_canvas_screen.dart';

part 'app_router.g.dart';

/// Флаг временного отключения обязательной аутентификации для тестирования интерфейса.
const bool kBypassAuthForTesting = true;

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final supabase = ref.watch(supabaseProvider);

  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (kBypassAuthForTesting) {
        // Аутентификация отключена для тестирования: сразу открываем главную
        return null;
      }

      final session = supabase.auth.currentSession;
      final isLoggedIn = session != null;
      final isAuthRoute = state.uri.path == '/auth';

      if (!isLoggedIn && !isAuthRoute) return '/auth';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const TreeListScreen(),
      ),
      GoRoute(
        path: '/canvas',
        builder: (context, state) => const TreeCanvasScreen(),
      ),
      // Catch‑all route redirecting unknown paths to /
      GoRoute(
        path: '*',
        redirect: (BuildContext context, GoRouterState state) => '/',
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
}

// Extension for testing to expose current location
extension GoRouterLocationExtension on GoRouter {
  /// Returns the current location URI as a string.
  String get location => routerDelegate.currentConfiguration.uri.toString();
}
