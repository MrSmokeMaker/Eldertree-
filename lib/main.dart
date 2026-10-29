import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/utils/notification_service.dart';




Future<void> main() async {
  // Load environment variables (supabase credentials, etc.)
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with error handling
  try {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL', defaultValue: dotenv.get('SUPABASE_URL', fallback: 'YOUR_SUPABASE_URL')),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: dotenv.get('SUPABASE_ANON_KEY', fallback: 'YOUR_SUPABASE_ANON_KEY')),
    );
  } catch (e, stack) {
    // Log the error and exit gracefully
    print('Supabase initialization failed: $e');
    debugPrintStack(stack: stack);
    // Optionally, you could show a UI error screen here.
    return;
  }

  // Initialize notification service with error handling
  final container = ProviderContainer();
  try {
    await container.read(notificationServiceProvider).init();
  } catch (e) {
    print('Notification service init failed: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FamilyTreeApp(),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final container = ProviderContainer();
  await container.read(notificationServiceProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FamilyTreeApp(),
    ),
  );
}

class FamilyTreeApp extends ConsumerWidget {
  const FamilyTreeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Family Tree',
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D4A3E),
          surface: const Color(0xFFF9F8F6),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFD4AF37),
          surface: const Color(0xFF0F1115),
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
