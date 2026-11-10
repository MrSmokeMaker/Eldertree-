import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:family_tree_app/core/config/bootstrap.dart';
import 'package:family_tree_app/core/theme/theme.dart';
import 'package:family_tree_app/core/widgets/app_bootstrap_screens.dart';
import 'package:family_tree_app/features/onboarding/onboarding_provider.dart';
import 'package:family_tree_app/features/onboarding/onboarding_screen.dart';
import 'package:family_tree_app/main.dart';

/// Root widget.
///
/// IMPORTANT: every branch must sit inside a `MaterialApp`/`WidgetsApp`.
/// A bare `Scaffold` has no `Directionality` ancestor, `Scaffold.build` throws on
/// `Directionality.of(context)` and the user gets Flutter's grey release
/// `ErrorWidget` instead of the app.
class RootWidget extends ConsumerWidget {
  const RootWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool? onboardingCompleted = ref.watch(onboardingProvider);
    if (onboardingCompleted != true) {
      return _materialApp(
        home: onboardingCompleted == null
            ? const AppSplashScreen()
            : const OnboardingScreen(),
      );
    }

    // Onboarding is local and needs no backend. The backend configuration is
    // checked once the user reaches the screens that do need Supabase.
    final BootstrapResult bootstrap = ref.watch(bootstrapResultProvider);
    if (!bootstrap.ready) {
      return _materialApp(
        home: AppConfigurationScreen(
          message: bootstrap.message ?? 'Unknown initialization error.',
        ),
      );
    }

    return const FamilyTreeApp();
  }

  Widget _materialApp({required Widget home}) {
    return MaterialApp(
      title: 'Eldertree',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: home,
    );
  }
}
