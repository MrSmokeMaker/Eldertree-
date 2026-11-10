import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:family_tree_app/core/config/bootstrap.dart';
import 'package:family_tree_app/root_widget.dart' as app;

/// Regression: RootWidget used to return a bare OnboardingScreen without a
/// MaterialApp, so Scaffold.build crashed on Directionality.of(context) and the
/// user saw Flutter's grey release ErrorWidget instead of the app.
void main() {
  testWidgets('onboarding mounts inside a MaterialApp without exceptions',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{'onboarding_completed': false},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          bootstrapResultProvider
              .overrideWithValue(const BootstrapResult.ready()),
        ],
        child: const app.RootWidget(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('missing configuration shows the setup screen, not a blank page',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{'onboarding_completed': true},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          bootstrapResultProvider.overrideWithValue(
            const BootstrapResult.failed('missing keys'),
          ),
        ],
        child: const app.RootWidget(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Eldertree is not configured'), findsOneWidget);
    expect(find.textContaining('missing keys'), findsOneWidget);
  });
}
