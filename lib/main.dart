import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/utils/notification_service.dart';
import 'root_widget.dart' as root;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env file)
  await dotenv.load(fileName: '.env');

  // Initialize Supabase with credentials from .env
  try {
    await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL', fallback: 'YOUR_SUPABASE_URL'),
      anonKey:
          dotenv.get('SUPABASE_ANON_KEY', fallback: 'YOUR_SUPABASE_ANON_KEY'),
    );
  } catch (e, stack) {
    debugPrint('Supabase initialization failed: $e\n$stack');
    return;
  }

  // Initialize notification service
  final container = ProviderContainer();
  try {
    await container.read(notificationServiceProvider).init();
  } catch (e) {
    debugPrint('Notification service init failed: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const root.RootWidget(),
    ),
  );
}

class FamilyTreeApp extends ConsumerWidget {
  const FamilyTreeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Eldertree',
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
