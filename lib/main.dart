import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'core/utils/notification_service.dart';
import 'root_widget.dart' as root;
import 'core/cache/cache_manager.dart';

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

  await CacheManager.init();
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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
    );
  }
}
