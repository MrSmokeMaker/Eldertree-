import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/cache/cache_manager.dart';
import 'core/config/bootstrap.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'core/utils/notification_service.dart';
import 'root_widget.dart' as root;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Replace the grey release ErrorWidget with a readable message, so a future
  // widget-build failure never again looks like "the page is just grey".
  ErrorWidget.builder = _buildReadableErrorWidget;

  final BootstrapResult result = await _initializeSupabase();

  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[bootstrapResultProvider.overrideWithValue(result)],
  );

  // Services that may be unavailable on the web must not prevent startup.
  try {
    await container.read(notificationServiceProvider).init();
  } catch (error) {
    debugPrint('Notification service init failed: $error');
  }
  try {
    await CacheManager.init();
  } catch (error) {
    debugPrint('Cache init failed: $error');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const root.RootWidget(),
    ),
  );
}

/// Initializes Supabase. Never throws and never prevents `runApp`: without a
/// configuration the user gets an actionable screen instead of a blank page.
Future<BootstrapResult> _initializeSupabase() async {
  final SupabaseConfig config = await loadSupabaseConfig();
  if (!config.isValid) {
    return const BootstrapResult.failed(
      'Не заданы SUPABASE_URL и SUPABASE_ANON_KEY.\n\n'
      'Заполните assets/.env или передайте значения при сборке через '
      '--dart-define (команда указана ниже).',
    );
  }

  try {
    await Supabase.initialize(url: config.url, anonKey: config.anonKey);
  } catch (error, stack) {
    debugPrint('Supabase initialization failed: $error\n$stack');
    return BootstrapResult.failed('Не удалось инициализировать Supabase: $error');
  }

  return const BootstrapResult.ready();
}

/// Stand-in widget instead of the grey box. It depends on no Material or
/// Directionality ancestor, so it is safe anywhere in the tree.
Widget _buildReadableErrorWidget(FlutterErrorDetails details) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Container(
      color: const Color(0xFF1E1E1E),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Text(
        'Interface error:\n${details.exceptionAsString()}',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFFE6E6E6), fontSize: 14),
      ),
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
