import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_tree_app/core/theme/theme.dart';
import 'package:family_tree_app/features/auth/presentation/auth_screen.dart';

void main() {
  testWidgets('AuthScreen renders styled elements and theme properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const AuthScreen(),
        ),
      ),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Switch to Sign Up
    await tester.tap(find.text('Need an account? Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Create Archive'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
