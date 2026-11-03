import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_tree_app/core/router/app_router.dart';
import 'package:family_tree_app/core/config/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  testWidgets('router redirects unauthenticated users to /auth', (WidgetTester tester) async {
    final mockSupabase = MockSupabaseClient();
    final mockAuth = MockGoTrueClient();
    // Stub auth behavior.
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentSession).thenReturn(null);
    when(() => mockAuth.onAuthStateChange).thenAnswer((_) => const Stream.empty());

    final container = ProviderContainer(overrides: [
      supabaseProvider.overrideWithValue(mockSupabase),
    ]);
    final router = container.read(appRouterProvider);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
      ),
    ));
    await tester.pumpAndSettle();
    final currentPath = router.routerDelegate.currentConfiguration.uri.path;
    expect(currentPath, '/auth');
    container.dispose();
  });
}
