import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_tree_app/features/onboarding/onboarding_provider.dart';
import 'package:family_tree_app/features/onboarding/onboarding_screen.dart';
import 'package:family_tree_app/main.dart';

/// Корневой виджет: показывает онбординг при первом запуске, затем основное приложение.
class RootWidget extends ConsumerWidget {
  const RootWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(onboardingProvider);
    return completed ? const FamilyTreeApp() : const OnboardingScreen();
  }
}
