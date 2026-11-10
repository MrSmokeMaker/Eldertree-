import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Values can be provided at build time:
/// ```
/// flutter build web --release --base-href /Eldertree-/ \
///   --dart-define=SUPABASE_URL=https://<project>.supabase.co \
///   --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
/// ```
/// `--dart-define` wins over the `.env` file (the root file declared in
/// `pubspec.yaml`; at runtime the bundle serves it as `assets/.env`).
///
/// `SUPABASE_ANON_KEY` is still accepted as a legacy alias.
const String kSupabaseUrlFromEnv = String.fromEnvironment('SUPABASE_URL');

const String kSupabaseKeyFromEnv = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
  defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
);

/// Bootstrap outcome for the current run. Overridden in `main()` before `runApp()`.
final bootstrapResultProvider = Provider<BootstrapResult>(
  (ref) => throw StateError(
    'bootstrapResultProvider must be overridden in main()',
  ),
);

@immutable
class BootstrapResult {
  const BootstrapResult._({required this.ready, this.message});

  const BootstrapResult.ready() : this._(ready: true);

  const BootstrapResult.failed(String message)
      : this._(ready: false, message: message);

  final bool ready;
  final String? message;
}

@immutable
class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.publishableKey});

  final String url;
  final String publishableKey;

  bool get isValid => !_isPlaceholder(url) && !_isPlaceholder(publishableKey);
}

/// Empty value or an unfilled placeholder shipped with the `.env` template.
bool _isPlaceholder(String value) {
  final String v = value.trim();
  return v.isEmpty ||
      v == 'null' ||
      v.startsWith('YOUR_') ||
      v.contains('YOUR_SUPABASE');
}

/// Reads the Supabase configuration from `--dart-define`, falling back to
/// `.env`. Never throws: a missing configuration must not stop the app from
/// starting and showing a readable explanation.
Future<SupabaseConfig> loadSupabaseConfig() async {
  String url = kSupabaseUrlFromEnv;
  String key = kSupabaseKeyFromEnv;

  if (_isPlaceholder(url) || _isPlaceholder(key)) {
    try {
      await dotenv.load(fileName: '.env');
      if (_isPlaceholder(url)) {
        url = dotenv.env['SUPABASE_URL'] ?? '';
      }
      if (_isPlaceholder(key)) {
        key = dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
            dotenv.env['SUPABASE_ANON_KEY'] ??
            '';
      }
    } catch (error) {
      debugPrint('dotenv.load() failed: $error');
    }
  }

  return SupabaseConfig(url: url.trim(), publishableKey: key.trim());
}
